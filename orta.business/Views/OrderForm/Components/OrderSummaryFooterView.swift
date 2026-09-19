//
//  OrderSummaryFooterView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 15.09.2026.
//

import SwiftUI

struct OrderSummaryFooterView: View {
    let total: Int
    var isSubmitEnabled: Bool = true
    var submitLabel: String = "Создать заказ"
    var onSubmit: () -> Void = {}

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 1) {
                Text("Итого")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.4)
                    .textCase(.uppercase)
                    .foregroundStyle(.tertiary)

                Text(verbatim: "\(total.formatted()) ₸")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
            }
            .fixedSize(horizontal: true, vertical: false)

            Button(action: onSubmit) {
                Text(submitLabel)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color("AccentLabel"))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(isSubmitEnabled ? Color.brandAccent : Color.brandAccent.opacity(0.4))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!isSubmitEnabled)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(Color("Card"))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color("Line"))
                .frame(height: 1)
        }
    }
}

#Preview("Light Mode") {
    VStack {
        Spacer()
        OrderSummaryFooterView(total: 21_600, onSubmit: {})
    }
    .appBackground()
    .preferredColorScheme(.light)
}

#Preview("Disabled") {
    VStack {
        Spacer()
        OrderSummaryFooterView(total: 0, isSubmitEnabled: false, onSubmit: {})
    }
    .appBackground()
    .preferredColorScheme(.dark)
}
