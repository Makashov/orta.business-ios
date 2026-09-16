//
//  TodayStatsCardView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import SwiftUI

struct TodayStatsCardView: View {
    var date: Date = .now
    var revenue: Int = 184_500
    var currencySymbol: String = "₸"
    var newOrdersCount: Int = 12
    var closedOrdersCount: Int = 9

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Today")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.6)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(date, format: .dateTime.day().month(.wide).weekday(.abbreviated))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)
            }

            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(revenue, format: .number)
                    .font(.system(size: 30, weight: .bold))
                Text(currencySymbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            Text("Payments today")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                TodayStatTileView(color: .orange, count: newOrdersCount, label: "New orders")
                TodayStatTileView(color: .green, count: closedOrdersCount, label: "Closed")
            }
            .padding(.top, 4)
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 14, trailing: 16))
        .cardSurface(cornerRadius: 18)
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }
}

private struct TodayStatTileView: View {
    let color: Color
    let count: Int
    let label: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(color)
                    .frame(width: 7, height: 7)
                Text(count, format: .number)
                    .font(.system(size: 20, weight: .bold))
            }
            Text(label)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(11)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
    }
}

#Preview("Light Mode") {
    TodayStatsCardView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    TodayStatsCardView()
        .preferredColorScheme(.dark)
}
