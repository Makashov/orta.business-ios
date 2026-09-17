//
//  LogoutButtonView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import SwiftUI

struct LogoutButtonView: View {
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Log out")
            }
            .font(.system(size: 13.5, weight: .bold))
            .foregroundStyle(Color("DangerInk"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color("DangerSurface"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color("DangerLine"))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LogoutButtonView()
        .padding()
}
