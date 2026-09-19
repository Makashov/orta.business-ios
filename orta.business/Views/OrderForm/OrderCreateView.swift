//
//  OrderCreateView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 15.09.2026.
//

import SwiftUI

struct OrderCreateView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var phone = ""
    @State private var address = ""
    @State private var orderNumber = ""

    @State private var items: [OrderLineItem] = []
    @State private var isAddItemSheetPresented = false
    @State private var editingItem: OrderLineItem?

    @State private var status: OrderStatus = .new
    @State private var customerName = ""
    @State private var scheduledAt = ""
    @State private var delivery = ""
    @State private var discount = 0
    @State private var comment = ""

    private var total: Int { items.reduce(0) { $0 + $1.total } }

    private var isFormValid: Bool {
        !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                OrderContactCardView(phone: $phone, address: $address, orderNumber: $orderNumber)

                OrderPositionsCardView(
                    items: items,
                    onAdd: {
                        editingItem = nil
                        isAddItemSheetPresented = true
                    },
                    onSelect: { item in
                        editingItem = item
                        isAddItemSheetPresented = true
                    },
                    onRemove: { item in
                        items.removeAll { $0.id == item.id }
                    }
                )

                OrderAdditionalDetailsCardView(
                    status: $status,
                    customerName: $customerName,
                    scheduledAt: $scheduledAt,
                    delivery: $delivery,
                    discount: $discount,
                    comment: $comment
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle("Новый заказ")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            OrderSummaryFooterView(total: total, isSubmitEnabled: isFormValid) {
                dismiss()
            }
        }
        .orderAddItemSheet(
            isPresented: $isAddItemSheetPresented,
            catalogItems: CatalogItem.sample,
            editingItem: editingItem
        ) { item in
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index] = item
            } else {
                items.append(item)
            }
        }
    }
}

#Preview {
    OrderCreateView()
}
