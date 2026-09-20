//
//  OrderEditView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

struct OrderEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel: AuthViewModel?

    let order: Order

    @State private var phone: String
    @State private var address: String
    @State private var orderNumber = ""

    @State private var items: [OrderLineItem]
    @State private var isAddItemSheetPresented = false
    @State private var editingItem: OrderLineItem?

    @State private var status: OrderStatus
    @State private var customerName: String
    @State private var scheduledAt = ""
    @State private var delivery = ""
    @State private var discount = 0
    @State private var comment = ""

    @State private var payments: [OrderPayment] = []
    @State private var removedPayments: [OrderPayment] = []
    @State private var paymentSheet: PaymentSheet?

    private enum PaymentSheet: Identifiable {
        case record, finish

        var id: Self { self }
    }

    init(order: Order) {
        self.order = order
        _phone = State(initialValue: order.phone)
        _address = State(initialValue: order.address)
        _status = State(initialValue: order.status)
        _customerName = State(initialValue: order.name)
        // Orders from the list only carry a total, not their line items, so the
        // known sum is seeded as one editable position to keep totals and payments consistent.
        _items = State(initialValue: [
            OrderLineItem(name: "Заказ \(order.number)", quantity: 1, unitPrice: order.sum, unit: "шт")
        ])
    }

    private var payable: Int { max(items.reduce(0) { $0 + $1.total } - discount, 0) }
    private var paid: Int { payments.reduce(0) { $0 + $1.amount } }
    private var remaining: Int { max(payable - paid, 0) }
    private var canFinish: Bool { status != .done && status != .canceled }
    private var authorName: String { authViewModel?.session?.name ?? "" }

    private var isFormValid: Bool {
        !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var createdLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM, HH:mm"
        return "Создан \(formatter.string(from: order.date))"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                OrderContactCardView(phone: $phone, address: $address, orderNumber: $orderNumber)

                OrderStatusCardView(status: $status)

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

                OrderPaymentCardView(
                    total: payable,
                    payments: payments,
                    canFinish: canFinish,
                    hasRemovedPayments: !removedPayments.isEmpty,
                    onRecord: { paymentSheet = .record },
                    onFinish: { paymentSheet = .finish },
                    onRemove: { payment in
                        payments.removeAll { $0.id == payment.id }
                        removedPayments.append(payment)
                    },
                    onRestore: {
                        payments.append(contentsOf: removedPayments)
                        removedPayments = []
                    }
                )

                OrderAdditionalDetailsCardView(
                    status: $status,
                    customerName: $customerName,
                    scheduledAt: $scheduledAt,
                    delivery: $delivery,
                    discount: $discount,
                    comment: $comment,
                    showsStatus: false
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .sheet(item: $paymentSheet) { sheet in
            switch sheet {
            case .record:
                OrderPaymentSheetView(remaining: remaining) { amount, method in
                    payments.append(OrderPayment(amount: amount, method: method, author: authorName))
                }
            case .finish:
                OrderFinishSheetView(total: payable, paid: paid) { method in
                    if let method, remaining > 0 {
                        payments.append(OrderPayment(amount: remaining, method: method, author: authorName))
                    }
                    status = .done
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text(order.number)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(createdLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // More actions (share, delete, etc.) — not specified yet.
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            OrderSummaryFooterView(total: payable, isSubmitEnabled: isFormValid, submitLabel: "Сохранить") {
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
    NavigationStack {
        OrderEditView(order: Order.sample[3])
    }
    .environment(AuthViewModel())
}
