//
//  OrderDetailsCard.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

/// Shared card chrome for the order details screen sections.
struct OrderDetailsCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color("Card"))
            )
            .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
    }
}

struct OrderDetailsCaption: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .tracking(0.4)
            .textCase(.uppercase)
            .foregroundStyle(.tertiary)
    }
}

#Preview {
    OrderDetailsCard {
        OrderDetailsCaption(text: "Детали")
    }
    .padding()
    .appBackground()
}
