//
//  OrdersServicing.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import Foundation
import Pulse

protocol OrdersServicing {
    /// - Parameters:
    ///   - from/till: only applied together, per `GET /orders`' contract; either both or neither is sent.
    ///   - statusIDs: `nil` defers to the backend default (every status the caller's role may view).
    ///   - limit: `nil` defers to the backend default (30, capped at 100).
    func fetchOrders(query: String?, from: Date?, till: Date?, statusIDs: [Int]?, limit: Int?) async throws -> [OrderDTO]
    /// Per-status order counts for the given filter, keyed by status name. `status`/`limit`/`offset`
    /// have no effect on this endpoint, matching `GET /orders/counts`.
    func fetchOrderCounts(query: String?, from: Date?, till: Date?) async throws -> [String: Int]
    func fetchOrder(id: Int) async throws -> OrderDetailsDTO
    func fetchStatuses() async throws -> [OrderStatus]
    func createOrder(
        number: String,
        clientName: String,
        clientPhone: String,
        addressText: String,
        scheduledAt: Date?,
        deliveryAt: Date?,
        discount: Int,
        comment: String,
        items: [OrderLineItem]
    ) async throws -> OrderDTO
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

    func fetchOrders(query: String?, from: Date?, till: Date?, statusIDs: [Int]?, limit: Int?) async throws -> [OrderDTO] {
        var items = ordersQueryItems(query: query, from: from, till: till, statusIDs: statusIDs)
        if let limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        return try await fetch([OrderDTO].self, path: "orders", queryItems: items)
    }

    func fetchOrderCounts(query: String?, from: Date?, till: Date?) async throws -> [String: Int] {
        guard let authSession = sessionStore.loadSession() else {
            throw OrdersServiceError.notSignedIn
        }
        guard let baseURL = BuildConfig.apiBaseURL(tenant: authSession.companyCode) else {
            throw OrdersServiceError.invalidURL
        }

        var components = URLComponents(url: baseURL.appendingPathComponent("orders/counts"), resolvingAgainstBaseURL: false)
        let items = ordersQueryItems(query: query, from: from, till: till, statusIDs: nil)
        if !items.isEmpty { components?.queryItems = items }
        guard let url = components?.url else { throw OrdersServiceError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authSession.token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw OrdersServiceError.server(httpResponse.statusCode)
        }
        do {
            // Keys are status names, not snake_case fields, so this bypasses `JSONDecoder.orders`
            // to avoid its convertFromSnakeCase key strategy touching them.
            return try JSONDecoder().decode([String: Int].self, from: data)
        } catch {
            throw OrdersServiceError.decoding
        }
    }

    private func ordersQueryItems(query: String?, from: Date?, till: Date?, statusIDs: [Int]?) -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let query, !query.isEmpty {
            items.append(URLQueryItem(name: "q", value: query))
        }
        if let from, let till {
            items.append(URLQueryItem(name: "from", value: DateFormatter.orderDateOnly.string(from: from)))
            items.append(URLQueryItem(name: "till", value: DateFormatter.orderDateOnly.string(from: till)))
        }
        statusIDs?.forEach { items.append(URLQueryItem(name: "status", value: String($0))) }
        return items
    }

    func fetchOrder(id: Int) async throws -> OrderDetailsDTO {
        try await fetch(OrderDetailsDTO.self, path: "orders/\(id)")
    }

    func fetchStatuses() async throws -> [OrderStatus] {
        try await fetch([OrderStatus].self, path: "orders/statuses")
    }

    func createOrder(
        number: String,
        clientName: String,
        clientPhone: String,
        addressText: String,
        scheduledAt: Date?,
        deliveryAt: Date?,
        discount: Int,
        comment: String,
        items: [OrderLineItem]
    ) async throws -> OrderDTO {
        guard let authSession = sessionStore.loadSession() else {
            throw OrdersServiceError.notSignedIn
        }
        guard let baseURL = BuildConfig.apiBaseURL(tenant: authSession.companyCode) else {
            throw OrdersServiceError.invalidURL
        }

        let body = CreateOrderRequestBody(
            number: number,
            client: .init(name: clientName, phone: clientPhone),
            address: .init(text: addressText),
            scheduledAt: scheduledAt.map { DateFormatter.orderTimestamp.string(from: $0) },
            deliveryAt: deliveryAt.map { DateFormatter.orderTimestamp.string(from: $0) },
            discount: discount,
            comment: comment,
            items: items.enumerated().map { position, item in
                CreateOrderRequestBody.Item(
                    catalogItemId: item.catalogItemId,
                    name: item.name,
                    unitCode: item.unit,
                    kind: 0,
                    quantity: Double(item.quantity),
                    unitPrice: item.unitPrice,
                    priceAgreed: item.priceAgreed,
                    position: position,
                    comment: item.comment
                )
            }
        )

        var request = URLRequest(url: baseURL.appendingPathComponent("orders"))
        request.httpMethod = "POST"
        request.setValue("Bearer \(authSession.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder.orders.encode(body)

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw OrdersServiceError.server(httpResponse.statusCode)
        }
        do {
            return try JSONDecoder.orders.decode(OrderDTO.self, from: data)
        } catch {
            throw OrdersServiceError.decoding
        }
    }

    private func fetch<T: Decodable>(_ type: T.Type, path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        guard let authSession = sessionStore.loadSession() else {
            throw OrdersServiceError.notSignedIn
        }
        guard let baseURL = BuildConfig.apiBaseURL(tenant: authSession.companyCode) else {
            throw OrdersServiceError.invalidURL
        }

        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        if !queryItems.isEmpty { components?.queryItems = queryItems }
        guard let url = components?.url else { throw OrdersServiceError.invalidURL }

        var request = URLRequest(url: url)
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

/// Wire shape for `POST /api/orders`. Keys map to snake_case via `JSONEncoder.orders`.
private struct CreateOrderRequestBody: Encodable {
    struct Client: Encodable {
        let name: String
        let phone: String
    }

    struct Address: Encodable {
        let text: String
    }

    struct Item: Encodable {
        let catalogItemId: Int?
        let name: String
        let unitCode: String
        let kind: Int
        let quantity: Double
        let unitPrice: Int
        let priceAgreed: Bool
        let position: Int
        let comment: String
    }

    let number: String
    let client: Client
    let address: Address
    let scheduledAt: String?
    let deliveryAt: String?
    let discount: Int
    let comment: String
    let items: [Item]
    /// Payments are only recorded after the order exists, so a create request always sends an empty array.
    let payments: [Int] = []
}

extension DateFormatter {
    /// Formats/parses the naive `"yyyy-MM-dd'T'HH:mm"` timestamps `scheduled_at`/`delivery_at` use (no seconds, no offset).
    /// `nonisolated` since this is immutable, thread-safe formatting state with no main-actor ties.
    nonisolated static let orderTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return formatter
    }()

    /// Formats the `"YYYY-MM-DD"` dates `GET /orders`' `from`/`till` query params expect.
    nonisolated static let orderDateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

private extension JSONDecoder {
    static let orders: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

private extension JSONEncoder {
    static let orders: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
}
