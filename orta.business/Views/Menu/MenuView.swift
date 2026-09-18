//
//  MenuView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import SwiftUI

struct MenuView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var isConfirmingLogout = false

    var body: some View {
        VStack(spacing: 0) {
            ProfileBlockView()

            MenuListSectionView()

            Spacer()

            LogoutButtonView {
                isConfirmingLogout = true
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .appBackground()
        .alert(
            "Are you sure you want to log out?",
            isPresented: $isConfirmingLogout) {
                Button("Log out", role: .destructive) {
                    authViewModel.signOut()
                }
                Button("Cancel", role: .cancel) {}
            }
    }
}

#Preview("Light Mode") {
    MenuView()
        .environment(AuthViewModel())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    MenuView()
        .environment(AuthViewModel())
        .preferredColorScheme(.dark)
}
