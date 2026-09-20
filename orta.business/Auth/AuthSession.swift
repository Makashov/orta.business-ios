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
    /// The tenant subdomain used to sign in. The login response doesn't include
    /// it, so it's filled in locally — persisting it lets later API calls
    /// rebuild the tenant-scoped base URL without asking the user again.
    let companyCode: String

    var isValid: Bool { expiresAt > .now }

    init(token: String, expiresAt: Date, name: String, username: String, role: AuthRole, companyCode: String) {
        self.token = token
        self.expiresAt = expiresAt
        self.name = name
        self.username = username
        self.role = role
        self.companyCode = companyCode
    }

    private enum CodingKeys: String, CodingKey {
        case token
        case expiresAt = "expires_at"
        case name
        case username
        case role
        case companyCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decode(String.self, forKey: .token)
        expiresAt = try container.decode(Date.self, forKey: .expiresAt)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        role = try container.decode(AuthRole.self, forKey: .role)
        // Absent from the server's login response; the keychain-persisted copy
        // (written locally, see LiveAuthService) always has it.
        companyCode = try container.decodeIfPresent(String.self, forKey: .companyCode) ?? ""
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
