//
//  ContactLinks.swift
//  orta.business
//
//  Created by Nurbol Makashov on 24.09.2026.
//

import Foundation

/// `tel:`/WhatsApp deep links built from a raw phone string, shared by every
/// call/WhatsApp affordance (order details, list and home swipe actions).
enum ContactLinks {
    static func tel(_ phone: String) -> URL? {
        let allowed = phone.filter { $0.isNumber || $0 == "+" }
        guard !allowed.isEmpty else { return nil }
        return URL(string: "tel://\(allowed)")
    }

    /// wa.me requires digits only — no `+`, spaces or dashes.
    static func whatsApp(_ phone: String) -> URL? {
        let digits = phone.filter(\.isNumber)
        guard !digits.isEmpty else { return nil }
        return URL(string: "https://wa.me/\(digits)")
    }
}
