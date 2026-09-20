//
//  OrderDetailsHistoryCardView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

struct OrderDetailsHistoryCardView: View {
    let events: [OrderDetailsHistoryEvent]

    var body: some View {
        OrderDetailsCard {
            VStack(alignment: .leading, spacing: 12) {
                OrderDetailsCaption(text: "История")

                VStack(alignment: .leading, spacing: 13) {
                    ForEach(events) { event in
                        HStack(alignment: .top, spacing: 11) {
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(event.color)
                                .frame(width: 8, height: 8)
                                .padding(.top, 5)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(event.title)
                                    .font(.system(size: 12.5, weight: .semibold))
                                Text(event.subtitle)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    OrderDetailsHistoryCardView(events: [
        OrderDetailsHistoryEvent(title: "Оплата 10 000 ₸ · Kaspi QR", subtitle: "4 сент, 13:20 · Асель Н.", color: Color("GreenBase")),
        OrderDetailsHistoryEvent(title: "Заказ создан", subtitle: "4 сент, 13:05 · Асель Н.", color: Color("AmberBase")),
    ])
    .padding()
    .appBackground()
}
