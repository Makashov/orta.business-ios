//
//  OrderContactCardView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

struct OrderContactCardView: View {
    @Binding var phone: String
    @Binding var address: String
    @Binding var orderNumber: String

    /// Keeps `phone` always starting with "+7" (and never shorter than it), and
    /// normalizes pasted numbers that start with "8" or a bare "7" into that form.
    private var formattedPhone: Binding<String> {
        Binding(
            get: { phone },
            set: { phone = Self.normalizedPhone(old: phone, new: $0) }
        )
    }

    private static func normalizedPhone(old: String, new: String) -> String {
        if new.hasPrefix("+7") { return new }
        // A lone "+" means the "7" of "+7" was just deleted — restore the prefix.
        if new == "+" { return old.hasPrefix("+7") ? "+7" : new }
        if new.isEmpty { return old.isEmpty ? "" : "+7" }
        if new.hasPrefix("8") { return "+7" + new.dropFirst() }
        if new.hasPrefix("7") { return "+" + new }
        return "+7" + new
    }

    var body: some View {
        VStack(spacing: 0) {
            OrderFormFieldRow(
                icon: "phone.fill",
                iconColor: .brandAccent,
                title: "Телефон",
                isRequired: true,
                placeholder: "+7 ___ ___ __ __",
                text: formattedPhone,
                valueFont: .system(size: 17, weight: .semibold),
                keyboardType: .phonePad,
                textContentType: .telephoneNumber
            )

            Divider()

            OrderFormFieldRow(
                icon: "mappin",
                title: "Адрес",
                placeholder: "Улица, дом, квартира",
                text: $address,
                textContentType: .fullStreetAddress
            )

            Divider()

            OrderFormFieldRow(
                icon: "number",
                title: "Номер заказа",
                placeholder: "Необязательно",
                text: $orderNumber
            )
        }
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("Card"))
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
    }
}

#Preview("Light Mode") {
    OrderContactCardView(phone: .constant(""), address: .constant(""), orderNumber: .constant(""))
        .padding()
        .appBackground()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    OrderContactCardView(phone: .constant("+7 707 415 22 89"), address: .constant("ул. Абая 52, кв. 14"), orderNumber: .constant(""))
        .padding()
        .appBackground()
        .preferredColorScheme(.dark)
}
