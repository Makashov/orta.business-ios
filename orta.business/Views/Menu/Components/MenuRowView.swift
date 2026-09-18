//
//  MenuRowView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 17.09.2026.
//

import SwiftUI

struct MenuRowView: View {
    enum Trailing {
        case chevron
        case chevronUpDown
        case badge(Int)
    }

    let icon: String
    let iconColor: Color
    let iconBackground: Color
    let title: LocalizedStringKey
    var subtitle: String? = nil
    var trailing: Trailing = .chevron
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconBackground)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(iconColor)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundStyle(.primary)
                    if let subtitle {
                        Text(verbatim: subtitle)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer(minLength: 8)

                trailingView
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var trailingView: some View {
        switch trailing {
        case .chevron:
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color("Chev"))
        case .chevronUpDown:
            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color("Chev"))
        case .badge(let count):
            Text(count, format: .number)
                .font(.system(size: 10.5, weight: .bold))
                .foregroundStyle(.white)
                .frame(minWidth: 19, minHeight: 19)
                .background(Circle().fill(Color("DangerBase")))
        }
    }
}

#Preview("Light Mode") {
    VStack(spacing: 2) {
        MenuRowView(icon: "person.badge.shield.checkmark", iconColor: Color("AccentColor"), iconBackground: Color("AccentBg"), title: "Profile & Security")
        MenuRowView(icon: "gearshape", iconColor: Color("Icon"), iconBackground: Color("SlateSurface"), title: "Settings")
        MenuRowView(icon: "bell", iconColor: Color("DangerBase"), iconBackground: Color("DangerSurface"), title: "Notifications", trailing: .badge(3))
        MenuRowView(icon: "building.2", iconColor: .indigo, iconBackground: Color.indigo.opacity(0.15), title: "Organization", subtitle: "Tazabek · Almaty", trailing: .chevronUpDown)
        MenuRowView(icon: "questionmark.circle", iconColor: Color("TealBase"), iconBackground: Color("TealSurface"), title: "Help & Support")
    }
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    VStack(spacing: 2) {
        MenuRowView(icon: "person.badge.shield.checkmark", iconColor: Color("AccentColor"), iconBackground: Color("AccentBg"), title: "Profile & Security")
        MenuRowView(icon: "gearshape", iconColor: Color("Icon"), iconBackground: Color("SlateSurface"), title: "Settings")
        MenuRowView(icon: "bell", iconColor: Color("DangerBase"), iconBackground: Color("DangerSurface"), title: "Notifications", trailing: .badge(3))
        MenuRowView(icon: "building.2", iconColor: .indigo, iconBackground: Color.indigo.opacity(0.15), title: "Organization", subtitle: "Tazabek · Almaty", trailing: .chevronUpDown)
        MenuRowView(icon: "questionmark.circle", iconColor: Color("TealBase"), iconBackground: Color("TealSurface"), title: "Help & Support")
    }
    .padding()
    .preferredColorScheme(.dark)
}
