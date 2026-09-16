//
//  SessionStoring.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import Foundation
import Security

protocol SessionStoring {
    func save(_ session: AuthSession)
    func loadSession() -> AuthSession?
    func clear()
}

/// Persists the session token in the Keychain so it survives app relaunch.
struct KeychainSessionStore: SessionStoring {
    private let service = "orta.business.session"
    private let account = "current"

    func save(_ session: AuthSession) {
        guard let data = try? JSONEncoder.auth.encode(session) else { return }
        SecItemDelete(baseQuery as CFDictionary)
        var attributes = baseQuery
        attributes[kSecValueData as String] = data
        SecItemAdd(attributes as CFDictionary, nil)
    }

    func loadSession() -> AuthSession? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        return try? JSONDecoder.auth.decode(AuthSession.self, from: data)
    }

    func clear() {
        SecItemDelete(baseQuery as CFDictionary)
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}
