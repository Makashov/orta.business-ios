//
//  OrderSwipeActions.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

extension View {
    /// Trailing cancel/processing + leading WhatsApp swipe actions shared by every
    /// order row (List rows only). `orders` is mutated in place so the caller's
    /// filtering/derived state recomputes automatically.
    func orderSwipeActions(for order: Order, orders: Binding<[Order]>) -> some View {
        self
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    setStatus(order, to: .canceled, in: orders)
                } label: {
                    Label("Cancel", systemImage: "xmark")
                }
                .tint(Color("SlateBase"))

                if order.status == .new {
                    Button {
                        setStatus(order, to: .work, in: orders)
                    } label: {
                        Label("Processing", systemImage: "checkmark")
                    }
                    .tint(Color("AccentColor"))
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                Button {
                } label: {
                    Label("WhatsApp", image: "whatsApp")
                }
                .tint(Color("GreenBase"))
            }
    }
}

private func setStatus(_ order: Order, to status: OrderStatus, in orders: Binding<[Order]>) {
    guard let index = orders.wrappedValue.firstIndex(where: { $0.id == order.id }) else { return }
    orders.wrappedValue[index].status = status
}
