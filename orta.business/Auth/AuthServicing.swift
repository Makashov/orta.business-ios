//
//  AuthServicing.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import Foundation

protocol AuthServicing {
    func login(companyCode: String, username: String, password: String) async throws -> AuthSession
}

struct LiveAuthService: AuthServicing {
    func login(companyCode: String, username: String, password: String) async throws -> AuthSession {
        let tenant = companyCode.trimmingCharacters(in: .whitespaces)
        guard !tenant.isEmpty else {
            throw AuthError.invalidCompanyCode
        }

        // The company code is the tenant subdomain, e.g. "test" + "localhost:8080" -> http://test.localhost:8080
        let host = BuildConfig.apiBaseHost
        let scheme = host.contains(":") ? "http" : "https"
        guard let baseURL = URL(string: "\(scheme)://\(tenant).\(host)/api") else {
            throw AuthError.invalidCompanyCode
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("login"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(LoginRequestBody(username: username, password: password))

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AuthError.network
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.network
        }

        switch httpResponse.statusCode {
        case 200..<300:
            do {
                return try JSONDecoder.auth.decode(AuthSession.self, from: data)
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
