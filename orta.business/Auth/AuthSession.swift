//
//  AuthSession.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import Foundation

struct AuthSession: Codable, Equatable {
    let token: String
    let expiresAt: Date
    let name: String
    let username: String
    let role: AuthRole

    var isValid: Bool { expiresAt > .now }

    private enum CodingKeys: String, CodingKey {
        case token
        case expiresAt = "expires_at"
        case name
        case username
        case role
    }
}

struct AuthRole: Codable, Equatable {
    let id: Int
    let name: String
    let system: Bool
}

extension JSONDecoder {
    /// Decodes `expires_at`-style ISO-8601/RFC-3339 timestamps with a UTC offset (e.g. "+05:00").
    static let auth: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

extension JSONEncoder {
    static let auth: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}
