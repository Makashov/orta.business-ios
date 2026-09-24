//
//  OrderListItemView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import SwiftUI

struct OrderListItemView: View {
    let order: Order
    var currencySymbol: String = "₸"

    private var timeLabel: String {
        guard let scheduledAt = order.scheduledAt else {
            return "Дата не назначена"
        }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let time = timeFormatter.string(from: scheduledAt)

        if Calendar.current.isDateInToday(scheduledAt) {
            return "Сегодня, \(time)"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMM"
        return "\(dateFormatter.string(from: scheduledAt)), \(time)"
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(order.status.color.fill)
                .frame(width: 3)
                .frame(maxHeight: .infinity)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 7) {
                    Text(order.number)
                        .font(.system(size: 14.5, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(order.status.label)
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(order.status.color.ink)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(order.status.color.surface)
                        )
                }

                Text(order.displayName)
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(verbatim: "\(timeLabel) · \(order.address)")
                    .font(.system(size: 12.5))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text(verbatim: "\(order.sum.formatted()) \(currencySymbol)")
                .font(.system(size: 14.5, weight: .bold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(13)
        .frame(height: 93)
        .cardSurface(cornerRadius: 15)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
    }
}
