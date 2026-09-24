//
//  OrderCreateView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 15.09.2026.
//

import SwiftUI

struct OrderCreateView: View {
    @Environment(OrderStatusStore.self) private var statusStore: OrderStatusStore?

    @State private var phone = ""
    @State private var address = ""
    @State private var orderNumber = ""

    @State private var items: [OrderLineItem] = []
    @State private var isAddItemSheetPresented = false
    @State private var editingItem: OrderLineItem?
    @State private var catalogItems: [CatalogItem] = []

    @State private var status: OrderStatus = .new
    @State private var customerName = ""
    @State private var scheduledAt: Date?
    @State private var delivery: Date?
    @State private var discount = 0
    @State private var comment = ""

    @State private var isSubmitting = false
    @State private var submitError: String?
    @State private var createdOrder: Order?

    private let ordersService: any OrdersServicing = LiveOrdersService()
    private let catalogService: any CatalogServicing = LiveCatalogService()

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
            OrderSummaryFooterView(
                total: total,
                isSubmitEnabled: isFormValid && !isSubmitting,
                submitLabel: isSubmitting ? "Создание…" : "Создать заказ"
            ) {
                Task { await submit() }
            }
        }
        .orderAddItemSheet(
            isPresented: $isAddItemSheetPresented,
            catalogItems: catalogItems,
            editingItem: editingItem
        ) { item in
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index] = item
            } else {
                items.append(item)
            }
        }
        .task {
            if let initial = statusStore?.initialStatus {
                status = initial
            }
            catalogItems = (try? await catalogService.fetchCatalogItems()) ?? []
        }
        .alert(
            "Не удалось создать заказ",
            isPresented: Binding(get: { submitError != nil }, set: { if !$0 { submitError = nil } })
        ) {
            Button("ОК", role: .cancel) {}
        } message: {
            Text(submitError ?? "")
        }
        .navigationDestination(item: $createdOrder) { order in
            OrderDetailsView(order: order)
        }
    }

    private func submit() async {
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            let dto = try await ordersService.createOrder(
                number: orderNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                clientName: customerName.trimmingCharacters(in: .whitespacesAndNewlines),
                clientPhone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
                addressText: address.trimmingCharacters(in: .whitespacesAndNewlines),
                scheduledAt: scheduledAt,
                deliveryAt: delivery,
                discount: discount,
                comment: comment,
                items: items
            )
            createdOrder = Order(dto: dto, status: statusStore?.status(id: dto.status) ?? status)
        } catch {
            submitError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}

#Preview {
    OrderCreateView()
}
