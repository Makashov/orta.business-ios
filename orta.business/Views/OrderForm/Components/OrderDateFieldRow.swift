//
//  OrderDateFieldRow.swift
//  orta.business
//
//  Created by Nurbol Makashov on 22.09.2026.
//

import SwiftUI

/// A form row for an optional date+time value, styled to match `OrderFormFieldRow`.
/// Shows `placeholder` as a tappable button until a date is set, then a compact
/// `DatePicker` with a button to clear it back to `nil`.
struct OrderDateFieldRow: View {
    let icon: String
    var iconColor: Color = .secondary
    let title: String
    let placeholder: String
    @Binding var date: Date?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.4)
                    .textCase(.uppercase)
                    .foregroundStyle(.tertiary)

                if let date {
                    DatePicker(
                        "",
                        selection: Binding(get: { date }, set: { self.date = $0 }),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .environment(\.locale, Locale(identifier: "ru_RU"))
                } else {
                    Button(placeholder) { self.date = .now }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                        .buttonStyle(.plain)
                }
            }

            Spacer(minLength: 8)

            if date != nil {
                Button {
                    date = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 13)
    }
}

#Preview("Light Mode") {
    VStack(spacing: 0) {
        OrderDateFieldRow(icon: "calendar", title: "Дата и время", placeholder: "Не назначена", date: .constant(nil))
        Divider()
        OrderDateFieldRow(icon: "shippingbox", title: "Доставка", placeholder: "Не назначена", date: .constant(.now))
    }
    .padding(.horizontal, 16)
    .background(Color("Card"))
    .preferredColorScheme(.light)
}
