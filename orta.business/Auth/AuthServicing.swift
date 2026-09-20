//
//  AuthServicing.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import Foundation
import Pulse

protocol AuthServicing {
    func login(companyCode: String, username: String, password: String) async throws -> AuthSession
}

struct LiveAuthService: AuthServicing {
    // Routes requests through Pulse in debug builds so they show up in the
    // shake-triggered console; ordinary URLSession in release.
    private let session: any URLSessionProtocol = {
        #if DEBUG
        URLSessionProxy(configuration: .default)
        #else
        URLSession(configuration: .default)
        #endif
    }()

    func login(companyCode: String, username: String, password: String) async throws -> AuthSession {
        let tenant = companyCode.trimmingCharacters(in: .whitespaces)
        guard !tenant.isEmpty else {
            throw AuthError.invalidCompanyCode
        }

        guard let baseURL = BuildConfig.apiBaseURL(tenant: tenant) else {
            throw AuthError.invalidCompanyCode
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("login"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(LoginRequestBody(username: username, password: password))

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw AuthError.network
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.network
        }

        switch httpResponse.statusCode {
        case 200..<300:
            do {
                let decoded = try JSONDecoder.auth.decode(AuthSession.self, from: data)
                return AuthSession(
                    token: decoded.token,
                    expiresAt: decoded.expiresAt,
                    name: decoded.name,
                    username: decoded.username,
                    role: decoded.role,
                    companyCode: tenant
                )
            } catch {
                throw AuthError.decoding
            }
        case 401:
            throw AuthError.invalidCredentials
        default:
            let parsedMessage = (try? JSONDecoder().decode(ServerErrorBody.self, from: data))?.message
            throw AuthError.server(parsedMessage ?? String(localized: "Sign in failed. Please try again."))
        }
    }
}

private struct LoginRequestBody: Encodable {
    let username: String
    let password: String
}

private struct ServerErrorBody: Decodable {
    let message: String?
}
