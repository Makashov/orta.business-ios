//
//  OrderStatusCardView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

struct OrderStatusCardView: View {
    @Binding var status: OrderStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Статус")
                .font(.system(size: 10, weight: .bold))
                .tracking(0.4)
                .textCase(.uppercase)
                .foregroundStyle(.tertiary)

            OrderStatusPickerView(status: $status)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("Card"))
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
    }
}

#Preview("Light Mode") {
    OrderStatusCardView(status: .constant(.work))
        .padding()
        .appBackground()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    OrderStatusCardView(status: .constant(.done))
        .padding()
        .appBackground()
        .preferredColorScheme(.dark)
}
