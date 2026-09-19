//
//  MenuListSectionView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 17.09.2026.
//

import SwiftUI

struct MenuListSectionView: View {
    @AppStorage("isDarkModeOn") private var isDarkModeOn = false

    var organizationName: String = "Tazabek"
    var organizationCity: String = "Almaty"

    var onProfileAndSecurityTap: () -> Void = {}
    var onSettingsTap: () -> Void = {}
    var onNotificationsTap: () -> Void = {}
    var onOrganizationTap: () -> Void = {}
    var onHelpTap: () -> Void = {}

    var body: some View {
        VStack(spacing: 2) {
            MenuRowView(
                icon: "person.badge.shield.checkmark",
                iconColor: Color("AccentColor"),
                iconBackground: Color("AccentBg"),
                title: "Profile & Security",
                action: onProfileAndSecurityTap
            )

            MenuRowView(
                icon: "gearshape",
                iconColor: Color("Icon"),
                iconBackground: Color("SlateSurface"),
                title: "Settings",
                action: onSettingsTap
            )

            MenuRowView(
                icon: "bell",
                iconColor: Color("DangerBase"),
                iconBackground: Color("DangerSurface"),
                title: "Notifications",
                trailing: .badge(3),
                action: onNotificationsTap
            )

            MenuRowView(
                icon: "building.2",
                iconColor: .indigo,
                iconBackground: Color.indigo.opacity(0.15),
                title: "Organization",
                subtitle: "\(organizationName) · \(organizationCity)",
                trailing: .chevronUpDown,
                action: onOrganizationTap
            )

            MenuRowView(
                icon: "questionmark.circle",
                iconColor: Color("TealBase"),
                iconBackground: Color("TealSurface"),
                title: "Help & Support",
                action: onHelpTap
            )

            DarkModeRowView(isOn: $isDarkModeOn)
        }
        .padding(.horizontal, 12)
        .padding(.top, 16)
    }
}

#Preview("Light Mode") {
    MenuListSectionView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    MenuListSectionView()
        .preferredColorScheme(.dark)
}
