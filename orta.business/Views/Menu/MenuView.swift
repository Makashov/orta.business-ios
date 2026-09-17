//
//  MenuView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import SwiftUI

struct MenuView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        VStack {
            Spacer()

            LogoutButtonView {
                authViewModel.signOut()
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .appBackground()
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
