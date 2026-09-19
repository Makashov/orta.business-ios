//
//  OrderAdditionalDetailsCardView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

struct OrderAdditionalDetailsCardView: View {
    @Binding var status: OrderStatus
    @Binding var customerName: String
    @Binding var scheduledAt: String
    @Binding var delivery: String
    @Binding var discount: Int
    @Binding var comment: String
    var showsStatus: Bool = true

    @State private var isExpanded = false

    private var subtitle: String {
        showsStatus ? "Статус, имя, даты, скидка, комментарий" : "Имя, даты, скидка, комментарий"
    }

    private var discountText: Binding<String> {
        Binding(
            get: { discount == 0 ? "" : String(discount) },
            set: { discount = Int($0.filter(\.isNumber)) ?? 0 }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Дополнительно")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundStyle(.primary)
                        Text(subtitle)
                            .font(.system(size: 11.5, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)

                VStack(spacing: 0) {
                    if showsStatus {
                        statusRow

                        Divider()
                    }

                    OrderFormFieldRow(
                        icon: "person",
                        title: "Имя клиента",
                        placeholder: "Необязательно",
                        text: $customerName
                    )

                    Divider()

                    OrderFormFieldRow(
                        icon: "calendar",
                        title: "Дата и время",
                        placeholder: "Не назначена",
                        text: $scheduledAt
                    )

                    Divider()

                    OrderFormFieldRow(
                        icon: "shippingbox",
                        title: "Доставка",
                        placeholder: "Не назначена",
                        text: $delivery
                    )

                    Divider()

                    OrderFormFieldRow(
                        icon: "percent",
                        title: "Скидка, ₸",
                        placeholder: "0",
                        text: discountText,
                        keyboardType: .numberPad
                    )

                    Divider()

                    OrderFormFieldRow(
                        icon: "text.bubble",
                        title: "Комментарий",
                        placeholder: "Детали заказа",
                        text: $comment,
                        isMultiline: true
                    )
                }
                .padding(.horizontal, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("Card"))
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
    }

    private var statusRow: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "target")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 18)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 7) {
                Text("Статус")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.4)
                    .textCase(.uppercase)
                    .foregroundStyle(.tertiary)

                OrderStatusPickerView(status: $status)
            }
        }
        .padding(.vertical, 13)
    }
}

#Preview("Light Mode") {
    OrderAdditionalDetailsCardView(
        status: .constant(.new),
        customerName: .constant(""),
        scheduledAt: .constant(""),
        delivery: .constant(""),
        discount: .constant(0),
        comment: .constant("")
    )
    .padding()
    .appBackground()
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    OrderAdditionalDetailsCardView(
        status: .constant(.work),
        customerName: .constant("Дмитрий Ким"),
        scheduledAt: .constant(""),
        delivery: .constant(""),
        discount: .constant(1000),
        comment: .constant("")
    )
    .padding()
    .appBackground()
    .preferredColorScheme(.dark)
}
