//
//  ProfileBlockView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 17.09.2026.
//

import SwiftUI

struct ProfileBlockView: View {
    var initials: String = "АС"
    var fullName: String = "Асхат Сериков"
    var phoneNumber: String = "+7 701 234 56 78"
    var role: LocalizedStringKey = "Owner"

    var body: some View {
        HStack(spacing: 12) {
            Text(initials)
                .font(.system(size: 16.5, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color("AccentColor"))
                )
                .shadow(color: Color("AccentColor").opacity(0.32), radius: 8, y: 4)

            VStack(alignment: .leading, spacing: 3) {
                Text(fullName)
                    .font(.system(size: 15.5, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 7) {
                    Text(phoneNumber)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)

                    Circle()
                        .fill(Color("Chev"))
                        .frame(width: 3, height: 3)

                    Text(role)
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(Color("AccentInk"))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.top, 12)
        .padding(.horizontal, 20)
        .padding(.bottom, 18)
        .background(Color("Card2"))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color("Line"))
                .frame(height: 1)
        }
    }
}

#Preview("Light Mode") {
    ProfileBlockView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ProfileBlockView()
        .preferredColorScheme(.dark)
}
