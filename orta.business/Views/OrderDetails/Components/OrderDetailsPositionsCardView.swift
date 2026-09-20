//
//  OrderDetailsPositionsCardView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

struct OrderDetailsPositionsCardView: View {
    let items: [OrderLineItem]

    private var total: Int { items.reduce(0) { $0 + $1.total } }

    var body: some View {
        OrderDetailsCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    OrderDetailsCaption(text: "Позиции")
                    Spacer()
                    Text(verbatim: "\(items.count) поз.")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }

                VStack(spacing: 8) {
                    ForEach(items) { item in
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .lineLimit(1)
                                Text(verbatim: subtitle(for: item))
                                    .font(.system(size: 11.5, weight: .medium))
                                    .foregroundStyle(.tertiary)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 0)
                            Text(verbatim: "\(item.total.formatted()) ₸")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 11)
                        .background(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .fill(Color("Bg"))
                        )
                    }
                }
                .padding(.top, 10)

                Divider()
                    .padding(.top, 12)

                HStack {
                    Text("Итого")
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(verbatim: "\(total.formatted()) ₸")
                        .font(.system(size: 16, weight: .bold))
                }
                .padding(.top, 12)
            }
        }
    }

    private func subtitle(for item: OrderLineItem) -> String {
        let calc = "\(item.quantity) \(item.unit) × \(item.unitPrice.formatted()) ₸"
        return item.comment.isEmpty ? calc : "\(item.comment) · \(calc)"
    }
}

#Preview {
    OrderDetailsPositionsCardView(items: [
        OrderLineItem(name: "Химчистка дивана", quantity: 1, unitPrice: 12_000, unit: "шт", comment: "3-местный"),
        OrderLineItem(name: "Чистка ковра", quantity: 8, unitPrice: 1_200, unit: "м²"),
    ])
    .padding()
    .appBackground()
}
