//
//  OrderPositionsCardView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

struct OrderPositionsCardView: View {
    let items: [OrderLineItem]
    var onAdd: () -> Void = {}
    var onSelect: (OrderLineItem) -> Void = { _ in }
    var onRemove: (OrderLineItem) -> Void = { _ in }

    private var total: Int { items.reduce(0) { $0 + $1.total } }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text("Позиции")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.4)
                    .textCase(.uppercase)
                    .foregroundStyle(.tertiary)

                if !items.isEmpty {
                    Spacer()
                    Text(verbatim: "\(items.count) · \(total.formatted()) ₸")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }

            if items.isEmpty {
                Text("Добавьте услугу или товар из каталога — можно и после создания заказа.")
                    .font(.system(size: 12.5))
                    .foregroundStyle(.tertiary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                addButton
            } else {
                VStack(spacing: 8) {
                    ForEach(items) { item in
                        OrderLineItemRowView(
                            item: item,
                            onTap: { onSelect(item) },
                            onRemove: { onRemove(item) }
                        )
                    }
                }
                .padding(.top, 10)

                addButton
                    .padding(.top, 10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("Card"))
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)

        if !items.isEmpty {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 13))
                    .foregroundStyle(.tertiary)

                Text("Тап по позиции — правка, × — удалить")
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 6)
            .padding(.top, 12)
        }
    }

    private var addButton: some View {
        Button(action: onAdd) {
            HStack(spacing: 7) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                Text("Добавить позицию")
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundStyle(Color.brandAccent)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(items.isEmpty ? Color.brandAccent.opacity(0.08) : Color("Card"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(
                        items.isEmpty ? Color.brandAccent : Color("Line"),
                        style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Empty") {
    OrderPositionsCardView(items: [])
        .padding()
        .appBackground()
}

#Preview("With items") {
    OrderPositionsCardView(items: [
        OrderLineItem(name: "Химчистка дивана", category: "Химчистка", quantity: 1, unitPrice: 12_000, unit: "шт", comment: "3-местный"),
        OrderLineItem(name: "Чистка ковра", category: "Ковры", quantity: 8, unitPrice: 1_200, unit: "м²"),
    ])
    .padding()
    .appBackground()
}
