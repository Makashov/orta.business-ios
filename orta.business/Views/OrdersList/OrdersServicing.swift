//
//  OrdersServicing.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import Foundation
import Pulse

protocol OrdersServicing {
    /// Raw response body — kept undecoded since the server's `Order` JSON shape
    /// isn't established yet; the list screen still runs on local sample data.
    @discardableResult
    func fetchOrders() async throws -> Data
}

enum OrdersServiceError: LocalizedError {
    case notSignedIn
    case invalidURL
    case server(Int)

    var errorDescription: String? {
        switch self {
        case .notSignedIn: "Not signed in."
        case .invalidURL: "Couldn't build the orders URL for the current session."
        case .server(let code): "Server returned \(code)."
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

    @discardableResult
    func fetchOrders() async throws -> Data {
        guard let authSession = sessionStore.loadSession() else {
            throw OrdersServiceError.notSignedIn
        }
        guard let baseURL = BuildConfig.apiBaseURL(tenant: authSession.companyCode) else {
            throw OrdersServiceError.invalidURL
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("orders"))
        request.httpMethod = "GET"
        request.setValue("Bearer \(authSession.token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw OrdersServiceError.server(httpResponse.statusCode)
        }
        return data
    }
}
