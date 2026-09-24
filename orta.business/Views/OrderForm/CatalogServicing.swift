//
//  CatalogServicing.swift
//  orta.business
//
//  Created by Nurbol Makashov on 22.09.2026.
//

import Foundation
import Pulse

protocol CatalogServicing {
    func fetchCatalogItems() async throws -> [CatalogItem]
}

private struct CatalogItemDTO: Decodable {
    let id: Int
    let name: String
    let unitCode: String
    let unitPrice: Int?
    let isActive: Bool
}

struct LiveCatalogService: CatalogServicing {
    private let sessionStore: SessionStoring

    // Routes through Pulse in debug builds, same as the other services.
    private let session: any URLSessionProtocol = {
        #if DEBUG
        URLSessionProxy(configuration: .default)
        #else
        URLSession(configuration: .default)
        #endif
    }()

    init(sessionStore: SessionStoring = KeychainSessionStore()) {
        self.sessionStore = sessionStore
    }

    func fetchCatalogItems() async throws -> [CatalogItem] {
        guard let authSession = sessionStore.loadSession() else {
            throw OrdersServiceError.notSignedIn
        }
        guard let baseURL = BuildConfig.apiBaseURL(tenant: authSession.companyCode) else {
            throw OrdersServiceError.invalidURL
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("catalog"))
        request.httpMethod = "GET"
        request.setValue("Bearer \(authSession.token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw OrdersServiceError.server(httpResponse.statusCode)
        }
        do {
            let dtos = try JSONDecoder.catalog.decode([CatalogItemDTO].self, from: data)
            return dtos
                .filter(\.isActive)
                .map { CatalogItem(id: $0.id, name: $0.name, unitCode: $0.unitCode, unitPrice: $0.unitPrice) }
        } catch {
            throw OrdersServiceError.decoding
        }
    }
}

private extension JSONDecoder {
    static let catalog: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
