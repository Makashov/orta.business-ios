//
//  OrderDetailsInfoCardView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

struct OrderDetailsInfoCardView: View {
    let rows: [OrderDetailsInfoRow]

    var body: some View {
        OrderDetailsCard {
            VStack(alignment: .leading, spacing: 11) {
                OrderDetailsCaption(text: "Детали")

                VStack(spacing: 10) {
                    ForEach(rows) { row in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(row.title)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.tertiary)
                                .frame(width: 112, alignment: .leading)
                            Text(row.value)
                                .font(.system(size: 13, weight: .semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    OrderDetailsInfoCardView(rows: [
        OrderDetailsInfoRow(title: "Дата создания", value: "4 сентября 2026, 13:05"),
        OrderDetailsInfoRow(title: "Оператор", value: "Асель Н."),
        OrderDetailsInfoRow(title: "Комментарий", value: "Позвонить за час до выезда, дома кошка"),
    ])
    .padding()
    .appBackground()
}
