//
//  OrderLineItem.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import Foundation

struct OrderLineItem: Identifiable, Equatable {
    let id: UUID
    var name: String
    var category: String?
    var quantity: Int
    var unitPrice: Int
    var unit: String
    var comment: String

    var total: Int { quantity * unitPrice }

    init(
        id: UUID = UUID(),
        name: String,
        category: String? = nil,
        quantity: Int,
        unitPrice: Int,
        unit: String,
        comment: String = ""
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.unit = unit
        self.comment = comment
    }
}
