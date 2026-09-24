//
//  OrderDetailsView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

/// Order details screen. Shows the list's `Order` immediately, then fills in the rest
/// from `GET /api/orders/:id`.
struct OrderDetailsView: View {
    let order: Order

    @Environment(OrderStatusStore.self) private var statusStore: OrderStatusStore?
    @Environment(\.openURL) private var openURL

    @State private var details: OrderDetails?
    @State private var loadError: String?
    @State private var isEditPresented = false

    private let ordersService: any OrdersServicing = LiveOrdersService()

    private var current: Order { details?.order ?? order }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if let loadError {
                    Text(loadError)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color("DangerInk"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                OrderDetailsSummaryCardView(
                    status: current.status,
                    createdLabel: details?.createdAt.map { "Создан \(Self.shortDateTime($0))" } ?? "",
                    total: current.sum,
                    paid: details?.paid ?? 0
                )

                OrderDetailsCustomerCardView(
                    name: current.displayName,
                    subtitle: details?.clientOrderCount.map { "Заказов: \($0)" },
                    phone: current.phone,
                    onCall: { call(current.phone) },
                    onWhatsApp: { openWhatsApp(current.phone) }
                )

                OrderDetailsAddressCardView(address: current.address)

                if let details {
                    if !details.items.isEmpty {
                        OrderDetailsPositionsCardView(items: details.items)
                    }

                    if !infoRows(for: details).isEmpty {
                        OrderDetailsInfoCardView(rows: infoRows(for: details))
                    }

                    if !history(for: details).isEmpty {
                        OrderDetailsHistoryCardView(events: history(for: details))
                    }
                } else if loadError == nil {
                    ProgressView()
                        .padding(.top, 12)
                }
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
                Text(verbatim: "Заказ \(current.number)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isEditPresented = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Редактировать")
            }
        }
        .safeAreaInset(edge: .bottom) {
            OrderDetailsActionBarView(onEdit: { isEditPresented = true })
        }
        .navigationDestination(isPresented: $isEditPresented) {
            OrderEditView(order: current)
        }
        .task {
            await loadDetails()
        }
        .refreshable {
            await loadDetails()
        }
    }

    // MARK: - Contact actions

    private func call(_ phone: String) {
        guard let url = ContactLinks.tel(phone) else { return }
        openURL(url)
    }

    private func openWhatsApp(_ phone: String) {
        guard let url = ContactLinks.whatsApp(phone) else { return }
        openURL(url)
    }

    // MARK: - Loading

    private func loadDetails() async {
        do {
            let dto = try await ordersService.fetchOrder(id: order.id)
            await statusStore?.load()
            details = OrderDetails(dto: dto, status: statusStore?.status(id: dto.status) ?? order.status)
            loadError = nil
        } catch {
            loadError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    // MARK: - Content

    private func infoRows(for details: OrderDetails) -> [OrderDetailsInfoRow] {
        var rows: [OrderDetailsInfoRow] = []
        if let createdAt = details.createdAt {
            rows.append(OrderDetailsInfoRow(title: "Дата создания", value: Self.longDateTime(createdAt)))
        }
        if let scheduledAt = details.order.scheduledAt {
            rows.append(OrderDetailsInfoRow(title: "Дата выполнения", value: Self.longDateTime(scheduledAt)))
        }
        if let deliveryAt = details.deliveryAt {
            rows.append(OrderDetailsInfoRow(title: "Дата доставки", value: Self.longDateTime(deliveryAt)))
        }
        if details.discount > 0 {
            rows.append(OrderDetailsInfoRow(title: "Скидка", value: "\(details.discount.formatted()) ₸"))
        }
        if !details.comment.isEmpty {
            rows.append(OrderDetailsInfoRow(title: "Комментарий", value: details.comment))
        }
        return rows
    }

    /// Newest first: payments, then order creation.
    private func history(for details: OrderDetails) -> [OrderDetailsHistoryEvent] {
        let payments = details.payments
            .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
            .map { payment in
                OrderDetailsHistoryEvent(
                    title: ["Оплата \(payment.amount.formatted()) ₸", payment.method?.label]
                        .compactMap { $0 }
                        .joined(separator: " · "),
                    subtitle: payment.date.map(Self.shortDateTime) ?? "",
                    color: Color("GreenBase")
                )
            }
        let created = details.createdAt.map {
            OrderDetailsHistoryEvent(title: "Заказ создан", subtitle: Self.shortDateTime($0), color: Color("AmberBase"))
        }
        return payments + [created].compactMap { $0 }
    }

    /// "4 сент, 13:05"
    private static func shortDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM, HH:mm"
        return formatter.string(from: date).replacingOccurrences(of: ".", with: "")
    }

    /// "4 сентября 2026, 13:05"
    private static func longDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy, HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        OrderDetailsView(order: Order.sample[3])
    }
}
