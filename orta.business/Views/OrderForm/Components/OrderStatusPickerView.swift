//
//  OrderStatusPickerView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

/// The wrapping row of status pills, shared by the standalone status card
/// (edit form) and the status row inside "Дополнительно" (create form).
struct OrderStatusPickerView: View {
    @Binding var status: OrderStatus

    var body: some View {
        FlowLayout(spacing: 7, lineSpacing: 7) {
            ForEach(OrderStatus.allCases, id: \.self) { candidate in
                pill(candidate)
            }
        }
    }

    private func pill(_ candidate: OrderStatus) -> some View {
        let isActive = status == candidate
        return Button {
            status = candidate
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(candidate.color.fill)
                    .frame(width: 7, height: 7)

                Text(candidate.label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.primary.opacity(0.85))
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isActive ? candidate.color.surface : Color("Card2"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(isActive ? candidate.color.fill : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OrderStatusPickerView(status: .constant(.work))
        .padding()
        .appBackground()
}
