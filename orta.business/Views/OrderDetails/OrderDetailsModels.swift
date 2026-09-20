//
//  OrderDetailsHistoryEvent.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

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
