//
//  CatalogItem.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import Foundation

struct CatalogItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let unitPrice: Int
    let unit: String

    static let categories = ["Все", "Химчистка", "Ковры", "Мебель", "Шторы"]

    static let sample: [CatalogItem] = [
        CatalogItem(name: "Химчистка дивана", category: "Химчистка", unitPrice: 12_000, unit: "шт"),
        CatalogItem(name: "Чистка ковра", category: "Ковры", unitPrice: 1_200, unit: "м²"),
        CatalogItem(name: "Химчистка кресла", category: "Химчистка", unitPrice: 5_000, unit: "шт"),
        CatalogItem(name: "Чистка матраса", category: "Химчистка", unitPrice: 9_000, unit: "шт"),
        CatalogItem(name: "Стирка шторы", category: "Шторы", unitPrice: 2_500, unit: "м²"),
    ]
}
