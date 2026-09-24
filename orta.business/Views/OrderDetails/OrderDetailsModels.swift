//
//  OrderDetailsHistoryEvent.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

/// Raw `GET /api/orders/:id` shape. Keys map from snake_case via `JSONDecoder.orders`.
struct OrderDetailsDTO: Decodable {
    struct Client: Decodable {
        let name: String
        let phone: String
        let orderCount: Int?
    }

    struct Item: Decodable {
        let catalogItemId: Int?
        let name: String
        let unitCode: String
        let quantity: Double
        let unitPrice: Int
        let priceAgreed: Bool
        let position: Int
        let comment: String?
    }

    struct Payment: Decodable {
        let amount: Int
        /// Server-side payment method id, see `PaymentMethod.serverId`; `0` means none selected.
        let method: Int
        /// ISO 8601 with fractional seconds, e.g. `"2026-08-31T18:08:56.836378Z"`.
        let paidAt: String?
    }

    let id: Int
    let number: String
    let status: Int
    let client: Client
    let address: OrderDTO.Address
    let scheduledAt: String?
    let deliveryAt: String?
    /// ISO 8601 with fractional seconds, e.g. `"2026-08-28T19:49:26.05501Z"`.
    let createdAt: String
    let discount: Int
    /// Omitted by the server when the order has no comment.
    let comment: String?
    let items: [Item]
    let payments: [Payment]
    let total: Int
    let paid: Int
}

/// `OrderDetailsDTO` resolved into what the details screen renders.
struct OrderDetails {
    struct Payment {
        let amount: Int
        /// `nil` when no method was selected (id `0`) or the id is unknown.
        let method: PaymentMethod?
        let date: Date?
    }

    let order: Order
    let clientOrderCount: Int?
    /// `nil` when the address has no coordinates (typed by hand rather than picked from
    /// a Google Places prediction) — hides the 2GIS button.
    let lat: Double?
    let lng: Double?
    let deliveryAt: Date?
    let createdAt: Date?
    let discount: Int
    let comment: String
    let items: [OrderLineItem]
    let payments: [Payment]
    let paid: Int

    /// - Parameter status: resolved from `dto.status` via `OrderStatusStore`.
    init(dto: OrderDetailsDTO, status: OrderStatus) {
        order = Order(
            id: dto.id,
            sum: dto.total,
            scheduledAt: dto.scheduledAt.flatMap(Date.init(orderTimestamp:)),
            address: dto.address.text,
            name: dto.client.name,
            phone: dto.client.phone,
            status: status,
            number: dto.number
        )
        clientOrderCount = dto.client.orderCount
        lat = dto.address.lat
        lng = dto.address.lng
        deliveryAt = dto.deliveryAt.flatMap(Date.init(orderTimestamp:))
        createdAt = Date(orderTimestamp: dto.createdAt)
        discount = dto.discount
        comment = dto.comment ?? ""
        items = dto.items
            .sorted { $0.position < $1.position }
            .map { item in
                OrderLineItem(
                    catalogItemId: item.catalogItemId,
                    name: item.name,
                    quantity: Int(item.quantity.rounded()),
                    unitPrice: item.unitPrice,
                    unit: item.unitCode,
                    priceAgreed: item.priceAgreed,
                    comment: item.comment ?? ""
                )
            }
        payments = dto.payments.map { payment in
            Payment(
                amount: payment.amount,
                method: PaymentMethod(serverId: payment.method),
                date: payment.paidAt.flatMap(Date.init(orderTimestamp:))
            )
        }
        paid = dto.paid
    }
}

extension Date {
    /// Parses either the naive `"yyyy-MM-dd'T'HH:mm"` order timestamps or a full ISO 8601 one
    /// (with seconds/offset), which server-generated fields like `created_at` may use.
    ///
    /// `nonisolated` because this is pure formatting logic with no main-actor state, called
    /// point-free from `flatMap`, whose closure parameter type has no actor isolation.
    nonisolated init?(orderTimestamp string: String) {
        if let date = DateFormatter.orderTimestamp.date(from: string) {
            self = date
            return
        }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: string) {
            self = date
            return
        }
        iso.formatOptions = [.withInternetDateTime]
        guard let date = iso.date(from: string) else { return nil }
        self = date
    }
}

struct OrderDetailsHistoryEvent: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let color: Color
}

struct OrderDetailsInfoRow: Identifiable {
    let id = UUID()
    let title: String
    let value: String
}
