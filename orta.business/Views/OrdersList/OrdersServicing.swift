//
//  OrdersServicing.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import Foundation
import Pulse

protocol OrdersServicing {
    func fetchOrders() async throws -> [OrderDTO]
    func fetchStatuses() async throws -> [OrderStatus]
}

enum OrdersServiceError: LocalizedError {
    case notSignedIn
    case invalidURL
    case server(Int)
    case decoding

    var errorDescription: String? {
        switch self {
        case .notSignedIn: "Not signed in."
        case .invalidURL: "Couldn't build the orders URL for the current session."
        case .server(let code): "Server returned \(code)."
        case .decoding: "Couldn't read the server's response."
        }
    }
}

struct LiveOrdersService: OrdersServicing {
    private let sessionStore: SessionStoring

    // Routes through Pulse in debug builds, same as LiveAuthService.
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

    func fetchOrders() async throws -> [OrderDTO] {
        try await fetch([OrderDTO].self, path: "orders")
    }

    func fetchStatuses() async throws -> [OrderStatus] {
        try await fetch([OrderStatus].self, path: "orders/statuses")
    }

    private func fetch<T: Decodable>(_ type: T.Type, path: String) async throws -> T {
        guard let authSession = sessionStore.loadSession() else {
            throw OrdersServiceError.notSignedIn
        }
        guard let baseURL = BuildConfig.apiBaseURL(tenant: authSession.companyCode) else {
            throw OrdersServiceError.invalidURL
        }

        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "GET"
        request.setValue("Bearer \(authSession.token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw OrdersServiceError.server(httpResponse.statusCode)
        }
        do {
            return try JSONDecoder.orders.decode(T.self, from: data)
        } catch {
            throw OrdersServiceError.decoding
        }
    }
}

private extension JSONDecoder {
    static let orders: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
