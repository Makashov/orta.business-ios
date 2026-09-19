//
//  OrderFormFieldRow.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

struct OrderFormFieldRow: View {
    let icon: String
    var iconColor: Color = .secondary
    let title: String
    var isRequired: Bool = false
    let placeholder: String
    @Binding var text: String
    var valueFont: Font = .system(size: 15, weight: .medium)
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var isMultiline: Bool = false

    var body: some View {
        HStack(alignment: isMultiline ? .top : .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 18)
                .padding(.top, isMultiline ? 2 : 0)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.4)
                        .textCase(.uppercase)
                        .foregroundStyle(.tertiary)

                    if isRequired {
                        Text("*")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color("DangerBase"))
                    }
                }

                if isMultiline {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .font(valueFont)
                        .foregroundStyle(.primary)
                        .lineLimit(2...4)
                } else {
                    TextField(placeholder, text: $text)
                        .font(valueFont)
                        .foregroundStyle(.primary)
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                }
            }
        }
        .padding(.vertical, 13)
    }
}

#Preview("Light Mode") {
    VStack(spacing: 0) {
        OrderFormFieldRow(
            icon: "phone.fill",
            iconColor: .brandAccent,
            title: "Телефон",
            isRequired: true,
            placeholder: "+7 ___ ___ __ __",
            text: .constant(""),
            valueFont: .system(size: 17, weight: .semibold),
            keyboardType: .phonePad
        )
        Divider()
        OrderFormFieldRow(
            icon: "mappin",
            title: "Адрес",
            placeholder: "Улица, дом, квартира",
            text: .constant("ул. Абая 52, кв. 14")
        )
    }
    .padding(.horizontal, 16)
    .background(Color("Card"))
    .preferredColorScheme(.light)
}
