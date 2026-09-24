//
//  CatalogItem.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import Foundation

/// A `/api/catalog` item, resolved from `CatalogItemDTO`. `unitPrice` is `nil`
/// when the catalog entry has no fixed price and must be agreed per order.
struct CatalogItem: Identifiable, Hashable {
    let id: Int
    let name: String
    let unitCode: String
    let unitPrice: Int?

    static let sample: [CatalogItem] = [
        CatalogItem(id: 4, name: "Химчистка дивана", unitCode: "шт", unitPrice: nil),
        CatalogItem(id: 1, name: "Чистка ковра — синтетика", unitCode: "м²", unitPrice: 800),
        CatalogItem(id: 3, name: "Чистка ковра — шёлк", unitCode: "м²", unitPrice: 900),
        CatalogItem(id: 2, name: "Чистка ковра — шерсть", unitCode: "м²", unitPrice: 900),
    ]
}
