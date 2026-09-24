//
//  OrderSwipeActions.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI
import UIKit

extension View {
    /// Trailing cancel/processing + leading WhatsApp swipe actions shared by every
    /// order row (List rows only). `orders` is mutated in place so the caller's
    /// filtering/derived state recomputes automatically. `statuses` is the tenant's
    /// real status list, used to resolve the target of each action.
    func orderSwipeActions(for order: Order, orders: Binding<[Order]>, statuses: [OrderStatus]) -> some View {
        self
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                if let cancelled = statuses.first(where: { $0.isCancelled }) {
                    Button {
                        setStatus(order, to: cancelled, in: orders)
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .tint(Color("SlateBase"))
                }

                if order.status.isInitial, let inProgress = statuses.first(where: { !$0.isInitial && !$0.isTerminal }) {
                    Button {
                        setStatus(order, to: inProgress, in: orders)
                    } label: {
                        Label("Processing", systemImage: "checkmark")
                    }
                    .tint(Color("AccentColor"))
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                Button {
                    if let url = ContactLinks.whatsApp(order.phone) {
                        UIApplication.shared.open(url)
                    }
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
