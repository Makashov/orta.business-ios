//
//  OrderStatusFilter.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import Foundation

enum OrderStatusFilter: String, CaseIterable, Identifiable {
    case all, active, done, canceled

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: "Все"
        case .active: "Активные"
        case .done: "Завершённые"
        case .canceled: "Отменённые"
        }
    }

    func matches(_ status: OrderStatus) -> Bool {
        switch self {
        case .all: true
        case .active: status == .new || status == .work || status == .ready
        case .done: status == .done
        case .canceled: status == .canceled
        }
    }
}
