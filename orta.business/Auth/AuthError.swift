//
//  AuthError.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case invalidCompanyCode
    case server(String)
    case network
    case decoding

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            String(localized: "Invalid username or password")
        case .invalidCompanyCode:
            String(localized: "Enter a valid company code")
        case .server(let message):
            message
        case .network:
            String(localized: "Couldn't connect. Check your connection and try again")
        case .decoding:
            String(localized: "Unexpected response from server")
        }
    }
}
