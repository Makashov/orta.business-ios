//
//  LoginView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import SwiftUI

struct LoginView: View {
    @State private var companyCode = ""
    @State private var username = ""
    @State private var password = ""

    /// Layout-only for now — wired up once authentication is implemented.
    var onSignIn: (_ companyCode: String, _ username: String, _ password: String) -> Void = { _, _, _ in }

    private var canSubmit: Bool {
        !companyCode.trimmingCharacters(in: .whitespaces).isEmpty
            && !username.trimmingCharacters(in: .whitespaces).isEmpty
            && !password.isEmpty
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 28) {
                    brandHeader

                    VStack(spacing: 14) {
                        LoginFieldView(icon: "building.2", label: "Company code", text: $companyCode)
                        LoginFieldView(icon: "person", label: "Username", text: $username)
                        LoginFieldView(icon: "lock", label: "Password", text: $password, isSecure: true)
                    }

                    signInButton
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                .frame(minHeight: proxy.size.height)
            }
        }
        .appBackground()
    }

    private var brandHeader: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.brandAccent.opacity(0.15))
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(Color.brandAccent)
                )

            Text(verbatim: "Orta Business")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)

            Text("Sign in to your account")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }

    private var signInButton: some View {
        Button {
            onSignIn(companyCode, username, password)
        } label: {
            Text("Sign In")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.brandAccent)
                )
        }
        .buttonStyle(.plain)
        .opacity(canSubmit ? 1 : 0.5)
        .disabled(!canSubmit)
        .padding(.top, 6)
    }
}

private struct LoginFieldView: View {
    let icon: String
    let label: LocalizedStringKey
    @Binding var text: String
    var isSecure: Bool = false

    @State private var isRevealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.tertiary)
                    .frame(width: 18)

                Group {
                    if isSecure && !isRevealed {
                        SecureField(label, text: $text)
                    } else {
                        TextField(label, text: $text)
                    }
                }
                .font(.system(size: 15, weight: .medium))
                .autocorrectionDisabled()

                if isSecure {
                    Button {
                        isRevealed.toggle()
                    } label: {
                        Image(systemName: isRevealed ? "eye.slash" : "eye")
                            .font(.system(size: 14))
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color.primary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.1))
            )
        }
    }
}

#Preview("Light Mode") {
    LoginView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    LoginView()
        .preferredColorScheme(.dark)
}
