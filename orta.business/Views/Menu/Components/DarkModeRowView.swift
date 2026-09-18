//
//  DarkModeRowView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 17.09.2026.
//

import SwiftUI

struct DarkModeRowView: View {
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color("VioletSurface"))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "moon")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color("VioletBase"))
                )

            VStack(alignment: .leading, spacing: 1) {
                Text("Dark theme")
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(isOn ? "On" : "Off")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)
            }

            Spacer(minLength: 8)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color("AccentColor"))
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 8)
    }
}

#Preview("Light Mode") {
    DarkModeRowView(isOn: .constant(false))
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    DarkModeRowView(isOn: .constant(true))
        .padding()
        .preferredColorScheme(.dark)
}
