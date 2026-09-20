//
//  OrderDetailsView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

/// Layout-only order details screen. Content is static placeholder data until it is wired to the backend.
struct OrderDetailsView: View {
    let order: Order

    @State private var isMoreSheetPresented = false

    private let items = [
        OrderLineItem(name: "Химчистка дивана", quantity: 1, unitPrice: 12_000, unit: "шт", comment: "3-местный"),
        OrderLineItem(name: "Чистка ковра", quantity: 8, unitPrice: 1_200, unit: "м²"),
    ]

    private let infoRows = [
        OrderDetailsInfoRow(title: "Дата создания", value: "4 сентября 2026, 13:05"),
        OrderDetailsInfoRow(title: "Дата выполнения", value: "6 сентября, 14:00–17:00"),
        OrderDetailsInfoRow(title: "Оператор", value: "Асель Н."),
        OrderDetailsInfoRow(title: "Источник", value: "WhatsApp"),
        OrderDetailsInfoRow(title: "Комментарий", value: "Позвонить за час до выезда, дома кошка"),
    ]

    private let history = [
        OrderDetailsHistoryEvent(title: "Оплата 10 000 ₸ · Kaspi QR", subtitle: "4 сент, 13:20 · Асель Н.", color: Color("GreenBase")),
        OrderDetailsHistoryEvent(title: "Статус изменён на «В работе»", subtitle: "4 сент, 13:12 · Асель Н.", color: Color("AccentColor")),
        OrderDetailsHistoryEvent(title: "Заказ создан", subtitle: "4 сент, 13:05 · Асель Н.", color: Color("AmberBase")),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                OrderDetailsSummaryCardView(
                    status: order.status,
                    createdLabel: "Создан 4 сент, 13:05",
                    total: 21_600,
                    paid: 10_000
                )

                OrderDetailsCustomerCardView(
                    name: order.displayName,
                    subtitle: "7 заказов · с марта 2025",
                    phone: order.phone
                )

                OrderDetailsAddressCardView(address: order.address, note: "Подъезд 2, код 1244, 5 этаж")

                OrderDetailsPositionsCardView(items: items)

                OrderDetailsInfoCardView(rows: infoRows)

                OrderDetailsHistoryCardView(events: history)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text(verbatim: "Заказ \(order.number)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(verbatim: "2026-00417")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isMoreSheetPresented = true
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Ещё действия")
            }
        }
        .safeAreaInset(edge: .bottom) {
            OrderDetailsActionBarView()
        }
        .sheet(isPresented: $isMoreSheetPresented) {
            OrderDetailsMoreSheetView()
        }
    }
}

#Preview {
    NavigationStack {
        OrderDetailsView(order: Order.sample[3])
    }
}
