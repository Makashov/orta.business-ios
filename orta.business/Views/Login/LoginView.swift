//
//  LoginView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    @State private var companyCode = ""
    @State private var username = ""
    @State private var password = ""

    private var canSubmit: Bool {
        !companyCode.trimmingCharacters(in: .whitespaces).isEmpty
            && !username.trimmingCharacters(in: .whitespaces).isEmpty
            && !password.isEmpty
            && !authViewModel.isSigningIn
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
                    .disabled(authViewModel.isSigningIn)

                    if let errorMessage = authViewModel.errorMessage {
                        Text(verbatim: errorMessage)
                            .font(.system(size: 12.5, weight: .medium))
                            .foregroundStyle(Color("DangerInk"))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
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
                .fill(Color("AccentBg"))
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(Color("AccentColor"))
                )

            Text(verbatim: "Orta Business")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color("Ink"))

            Text("Sign in to your account")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color("Ink2"))
        }
    }

    private var signInButton: some View {
        Button {
            Task { await authViewModel.signIn(companyCode: companyCode, username: username, password: password) }
        } label: {
            ZStack {
                Text("Sign In")
                    .opacity(authViewModel.isSigningIn ? 0 : 1)

                if authViewModel.isSigningIn {
                    ProgressView()
                        .tint(.white)
                }
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(Color("AccentLabel"))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color("AccentColor"))
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
                .foregroundStyle(Color("Ink2"))

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color("Chev"))
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
                            .foregroundStyle(Color("Chev"))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color("Card"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(Color("Line"))
            )
        }
    }
}

#Preview("Light Mode") {
    LoginView()
        .environment(AuthViewModel())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    LoginView()
        .environment(AuthViewModel())
        .preferredColorScheme(.dark)
}
