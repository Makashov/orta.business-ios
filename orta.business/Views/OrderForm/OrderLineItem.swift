//
//  OrderLineItem.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import Foundation

struct OrderLineItem: Identifiable, Equatable {
    let id: UUID
    /// The `/api/catalog` item this was added from, or `nil` for a free-form position.
    var catalogItemId: Int?
    var name: String
    var quantity: Int
    var unitPrice: Int
    var unit: String
    /// True when `unitPrice` was manually set away from the catalog's default price
    /// (or there is no catalog default at all), rather than taken as-is.
    var priceAgreed: Bool
    var comment: String

    var total: Int { quantity * unitPrice }

    init(
        id: UUID = UUID(),
        catalogItemId: Int? = nil,
        name: String,
        quantity: Int,
        unitPrice: Int,
        unit: String,
        priceAgreed: Bool = false,
        comment: String = ""
    ) {
        self.id = id
        self.catalogItemId = catalogItemId
        self.name = name
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.unit = unit
        self.priceAgreed = priceAgreed
        self.comment = comment
    }
}
