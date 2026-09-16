//
//  AuthViewModel.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import Foundation
import Observation

@Observable
final class AuthViewModel {
    enum Status: Equatable {
        case signedOut
        case signingIn
        case signedIn(AuthSession)
        case failed(String)
    }

    private(set) var status: Status

    private let service: AuthServicing
    private let sessionStore: SessionStoring

    init(service: AuthServicing = LiveAuthService(), sessionStore: SessionStoring = KeychainSessionStore()) {
        self.service = service
        self.sessionStore = sessionStore
        if let session = sessionStore.loadSession(), session.isValid {
            status = .signedIn(session)
        } else {
            status = .signedOut
        }
    }

    var session: AuthSession? {
        if case .signedIn(let session) = status { session } else { nil }
    }

    var isSigningIn: Bool {
        if case .signingIn = status { true } else { false }
    }

    var errorMessage: String? {
        if case .failed(let message) = status { message } else { nil }
    }

    func signIn(companyCode: String, username: String, password: String) async {
        status = .signingIn
        do {
            let session = try await service.login(companyCode: companyCode, username: username, password: password)
            sessionStore.save(session)
            status = .signedIn(session)
        } catch {
            status = .failed((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
        }
    }

    func signOut() {
        sessionStore.clear()
        status = .signedOut
    }
}
