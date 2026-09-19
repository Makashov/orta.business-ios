//
//  OrderDateFilterButtonView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

struct OrderDateFilterButtonView: View {
    let label: String
    let subLabel: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: "calendar")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.brandAccent)

                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer(minLength: 8)

                Text(subLabel)
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .frame(height: 42)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color("Card"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(Color("Line"))
            )
            .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Light Mode") {
    OrderDateFilterButtonView(label: "Сегодня", subLabel: "4 сен")
        .padding()
        .appBackground()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    OrderDateFilterButtonView(label: "Всё время", subLabel: "Все даты")
        .padding()
        .appBackground()
        .preferredColorScheme(.dark)
}
