//
//  OrderStatus.swift
//  orta.business
//
//  Created by Nurbol Makashov on 22.09.2026.
//

import SwiftUI

struct StatusColor {
    let fill: Color
    let ink: Color
    let surface: Color
}

/// A tenant-defined order status, fetched from `/api/orders/statuses`. The set of
/// statuses (beyond `isInitial`/`isTerminal`) is configurable per tenant, so this
/// models the raw definition rather than a fixed case list.
struct OrderStatus: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String
    let system: Bool
    let isInitial: Bool
    let isTerminal: Bool

    var label: String { name }

    /// True for a terminal status that reads as a cancellation. The backend marks
    /// both a successful completion and a cancellation as `system + terminal`, so
    /// this is the only way to tell them apart.
    var isCancelled: Bool { name.localizedCaseInsensitiveContains("cancel") }

    /// Colors for the well-known status names, matched by name since the backend
    /// doesn't send styling. Anything unmatched (including "Cancelled" itself, and
    /// any custom tenant status) falls back to the cancelled/slate scheme.
    var color: StatusColor {
        switch name.lowercased() {
        case "created":
            StatusColor(fill: Color("AmberBase"), ink: Color("AmberInk"), surface: Color("AmberSurface"))
        case "in progress":
            StatusColor(fill: Color("AccentColor"), ink: Color("AccentInk"), surface: Color("AccentBg"))
        case "ready to deliver":
            StatusColor(fill: Color("TealBase"), ink: Color("TealInk"), surface: Color("TealSurface"))
        case "completed":
            StatusColor(fill: Color("GreenBase"), ink: Color("GreenInk"), surface: Color("GreenSurface"))
        default:
            StatusColor(fill: Color("SlateBase"), ink: Color("SlateInk"), surface: Color("SlateSurface"))
        }
    }
}

extension OrderStatus {
    /// Placeholder statuses used as defaults/previews before the real, tenant-specific
    /// list has loaded from the backend.
    static let new = OrderStatus(id: 1, name: "Created", system: true, isInitial: true, isTerminal: false)
    static let work = OrderStatus(id: 2, name: "In progress", system: false, isInitial: false, isTerminal: false)
    static let ready = OrderStatus(id: 3, name: "Ready to deliver", system: false, isInitial: false, isTerminal: false)
    static let done = OrderStatus(id: 4, name: "Completed", system: true, isInitial: false, isTerminal: true)
    static let canceled = OrderStatus(id: 5, name: "Cancelled", system: true, isInitial: false, isTerminal: true)

    static let samples: [OrderStatus] = [.new, .work, .ready, .done, .canceled]
}
