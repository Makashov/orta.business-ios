//
//  OrderPayment.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import Foundation

enum PaymentMethod: String, CaseIterable, Identifiable {
    case kaspiQR, kaspiTransfer, cash

    var id: String { rawValue }

    var label: String {
        switch self {
        case .kaspiQR: "Kaspi QR"
        case .kaspiTransfer: "Kaspi перевод"
        case .cash: "Наличные"
        }
    }

    var systemImage: String {
        switch self {
        case .kaspiQR: "qrcode"
        case .kaspiTransfer: "arrow.left.arrow.right"
        case .cash: "banknote"
        }
    }
}

struct OrderPayment: Identifiable, Hashable {
    let id = UUID()
    let amount: Int
    let method: PaymentMethod
    /// Name of the staff member who recorded the payment.
    let author: String
    let date: Date

    init(amount: Int, method: PaymentMethod, author: String, date: Date = .now) {
        self.amount = amount
        self.method = method
        self.author = author
        self.date = date
    }
}
