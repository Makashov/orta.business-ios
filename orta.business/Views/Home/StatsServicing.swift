//
//  StatsServicing.swift
//  orta.business
//
//  Created by Nurbol Makashov on 24.09.2026.
//

import Foundation
import Pulse

protocol StatsServicing {
    /// Revenue (sum of payment amounts, refunds included) for the given inclusive day range.
    /// Both `from` and `till` are required, per `GET /stats`'s contract.
    func fetchRevenue(from: Date, till: Date) async throws -> Int
}

enum StatsServiceError: LocalizedError {
    case notSignedIn
    case invalidURL
    case server(Int)
    case decoding

    var errorDescription: String? {
        switch self {
        case .notSignedIn: "Not signed in."
        case .invalidURL: "Couldn't build the stats URL for the current session."
        case .server(let code): "Server returned \(code)."
        case .decoding: "Couldn't read the server's response."
        }
    }
}

struct LiveStatsService: StatsServicing {
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

    func fetchRevenue(from: Date, till: Date) async throws -> Int {
        guard let authSession = sessionStore.loadSession() else {
            throw StatsServiceError.notSignedIn
        }
        guard let baseURL = BuildConfig.apiBaseURL(tenant: authSession.companyCode) else {
            throw StatsServiceError.invalidURL
        }

        var components = URLComponents(url: baseURL.appendingPathComponent("stats"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "from", value: DateFormatter.orderDateOnly.string(from: from)),
            URLQueryItem(name: "till", value: DateFormatter.orderDateOnly.string(from: till))
        ]
        guard let url = components?.url else { throw StatsServiceError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authSession.token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw StatsServiceError.server(httpResponse.statusCode)
        }
        do {
            return try JSONDecoder().decode(StatsResponseDTO.self, from: data).revenue
        } catch {
            throw StatsServiceError.decoding
        }
    }
}

/// Only the field `TodayStatsCardView` needs; the rest of `stats.response` (daily
/// breakdown, expenses, profit, clients, sales) is decoded away.
private struct StatsResponseDTO: Decodable {
    let revenue: Int
}
