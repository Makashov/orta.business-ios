//
//  RecentOrdersSectionView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import SwiftUI

struct RecentOrdersSectionView: View {
    @Environment(OrderStatusStore.self) private var statusStore: OrderStatusStore?

    @State private var orders: [Order] = []
    var currencySymbol: String = "₸"
    var onSeeAll: () -> Void = {}
    var onSelect: (Order) -> Void = { _ in }

    @State private var selectedOrder: Order?

    private let ordersService: any OrdersServicing = LiveOrdersService()

    // OrderListItemView rows are single-line throughout, so their height is constant.
    // Sizing the embedded List from that lets it sit inside HomeView's own ScrollView
    // (a List won't size itself to fit its content otherwise).
    private let rowHeight: CGFloat = 93
    private let rowSpacing: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Recent orders")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                Spacer()
                Button(action: onSeeAll) {
                    Text("See all")
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }

            List {
                ForEach(orders) { order in
                    Button {
                        selectedOrder = order
                        onSelect(order)
                    } label: {
                        OrderListItemView(order: order, currencySymbol: currencySymbol)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .orderSwipeActions(for: order, orders: $orders, statuses: statusStore?.statuses ?? [])
                }
            }
            .listStyle(.plain)
            #if os(iOS)
            .listRowSpacing(rowSpacing)
            #endif
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
            .frame(height: CGFloat(orders.count) * rowHeight + CGFloat(max(orders.count - 1, 0)) * rowSpacing)
        }
        .navigationDestination(item: $selectedOrder) { order in
            OrderDetailsView(order: order)
        }
        .task {
            await statusStore?.load()
            await loadOrders()
        }
    }

    private func loadOrders() async {
        guard let dtos = try? await ordersService.fetchOrders(
            query: nil,
            from: nil,
            till: nil,
            statusIDs: nil,
            limit: 5
        ) else { return }
        orders = dtos.map { dto in
            Order(dto: dto, status: statusStore?.status(id: dto.status) ?? .canceled)
        }
    }
}

#Preview("Light Mode") {
    RecentOrdersSectionView()
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    RecentOrdersSectionView()
        .padding()
        .preferredColorScheme(.dark)
}
