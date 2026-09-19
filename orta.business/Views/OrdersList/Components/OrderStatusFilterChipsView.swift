//
//  OrderStatusFilterChipsView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

struct OrderStatusFilterChipsView: View {
    @Binding var selection: OrderStatusFilter
    var counts: (OrderStatusFilter) -> Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(OrderStatusFilter.allCases) { filter in
                    chip(filter)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func chip(_ filter: OrderStatusFilter) -> some View {
        let isActive = selection == filter
        return Button {
            selection = filter
        } label: {
            HStack(spacing: 6) {
                Text(filter.label)
                    .font(.system(size: 12.5, weight: .semibold))

                Text("\(counts(filter))")
                    .font(.system(size: 11, weight: .bold))
                    .opacity(0.65)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .foregroundStyle(isActive ? Color("AccentLabel") : Color.primary.opacity(0.85))
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(isActive ? Color.brandAccent : Color("Card"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .strokeBorder(isActive ? Color.brandAccent : Color("Line"))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Light Mode") {
    OrderStatusFilterChipsView(selection: .constant(.all), counts: { _ in 4 })
        .appBackground()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    OrderStatusFilterChipsView(selection: .constant(.active), counts: { _ in 4 })
        .appBackground()
        .preferredColorScheme(.dark)
}
