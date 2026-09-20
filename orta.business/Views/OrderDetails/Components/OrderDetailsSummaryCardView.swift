//
//  OrderDetailsSummaryCardView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

struct OrderDetailsSummaryCardView: View {
    let status: OrderStatus
    let createdLabel: String
    let total: Int
    let paid: Int

    private var left: Int { max(total - paid, 0) }
    private var progress: Double { total > 0 ? min(Double(paid) / Double(total), 1) : 0 }

    private var balanceLabel: String {
        if paid == 0 { return "Не оплачено · \(total.formatted()) ₸" }
        if left == 0 { return "Оплачен полностью" }
        return "Остаток \(left.formatted()) ₸"
    }

    private var balanceColor: Color {
        if paid == 0 { return Color("DangerInk") }
        if left == 0 { return Color("GreenInk") }
        return Color("AmberInk")
    }

    var body: some View {
        OrderDetailsCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 9) {
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(status.color.fill)
                            .frame(width: 7, height: 7)
                        Text(status.label)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(status.color.ink)
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(status.color.surface)
                    )

                    Spacer()

                    Text(createdLabel)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundStyle(.tertiary)
                }

                Divider()
                    .padding(.top, 13)

                HStack(alignment: .bottom, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        OrderDetailsCaption(text: "Сумма заказа")
                        Text(verbatim: "\(total.formatted()) ₸")
                            .font(.system(size: 24, weight: .bold))
                            .tracking(-0.6)
                    }

                    Spacer()

                    if paid > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            OrderDetailsCaption(text: "Оплачено")
                            Text(verbatim: "\(paid.formatted()) ₸")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color("GreenInk"))
                        }
                    }
                }
                .padding(.top, 13)

                if paid > 0 {
                    GeometryReader { proxy in
                        Capsule()
                            .fill(Color("LineSoft"))
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(Color("GreenBase"))
                                    .frame(width: proxy.size.width * progress)
                            }
                    }
                    .frame(height: 6)
                    .padding(.top, 11)
                }

                Text(balanceLabel)
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundStyle(balanceColor)
                    .padding(.top, 9)
            }
        }
    }
}

#Preview("Partially paid") {
    OrderDetailsSummaryCardView(status: .work, createdLabel: "Создан 4 сент, 13:05", total: 21_600, paid: 10_000)
        .padding()
        .appBackground()
}

#Preview("Unpaid") {
    OrderDetailsSummaryCardView(status: .new, createdLabel: "Создан 4 сент, 13:05", total: 21_600, paid: 0)
        .padding()
        .appBackground()
}
