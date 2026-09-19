//
//  OrderLineItemRowView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

struct OrderLineItemRowView: View {
    let item: OrderLineItem
    var onTap: () -> Void = {}
    var onRemove: () -> Void = {}

    private var subtitle: String {
        let base = "\(item.quantity) \(item.unit) × \(item.unitPrice.formatted()) ₸"
        let comment = item.comment.trimmingCharacters(in: .whitespacesAndNewlines)
        return comment.isEmpty ? base : "\(comment) · \(base)"
    }

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text(verbatim: "\(item.total.formatted()) ₸")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: true, vertical: false)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.tertiary)
                    .frame(width: 26, height: 26)
                    .background(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(Color("Card"))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .strokeBorder(Color("Line"))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color("Card2"))
        )
    }
}

#Preview {
    VStack(spacing: 8) {
        OrderLineItemRowView(item: OrderLineItem(name: "Химчистка дивана", category: "Химчистка", quantity: 1, unitPrice: 12_000, unit: "шт", comment: "3-местный"))
        OrderLineItemRowView(item: OrderLineItem(name: "Чистка ковра", category: "Ковры", quantity: 8, unitPrice: 1_200, unit: "м²"))
    }
    .padding()
    .appBackground()
}
