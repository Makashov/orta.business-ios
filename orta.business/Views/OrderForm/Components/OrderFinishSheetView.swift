//
//  OrderFinishSheetView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

/// "Завершить заказ": settle the remaining balance with a chosen payment method
/// and mark the order as finished.
struct OrderFinishSheetView: View {
    let total: Int
    let paid: Int
    /// Called with the method used to settle the balance, or `nil` when nothing was left to pay.
    var onConfirm: (PaymentMethod?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var method: PaymentMethod = .cash

    private var remaining: Int { max(total - paid, 0) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color("GreenBase"))
                    .frame(width: 34, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(Color("GreenSurface"))
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text("Завершить заказ")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("Статус станет «Завершён»")
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundStyle(.tertiary)
                }

                Spacer(minLength: 8)

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color("Card2"))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Закрыть")
            }

            VStack(spacing: 8) {
                summaryRow("Итого по заказу", amount: total)
                summaryRow("Уже оплачено", amount: paid)

                Divider()

                HStack(alignment: .firstTextBaseline) {
                    Text("К списанию")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(verbatim: "\(remaining.formatted()) ₸")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color("Card2"))
            )
            .padding(.top, 14)

            if remaining > 0 {
                Text("Способ оплаты остатка")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.4)
                    .textCase(.uppercase)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 16)

                PaymentMethodPickerView(selection: $method, tint: .green)
                    .padding(.top, 9)
            }

            Button {
                onConfirm(remaining > 0 ? method : nil)
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                    Text(remaining > 0 ? "Оплатить и завершить" : "Завершить")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(Color("AccentLabel"))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color("GreenBase"))
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 18)
        }
        .padding(.horizontal, 16)
        .padding(.top, 22)
        .padding(.bottom, 16)
        .fittedSheetDetent()
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
    }

    private func summaryRow(_ title: String, amount: Int) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 12.5, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer()
            Text(verbatim: "\(amount.formatted()) ₸")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            OrderFinishSheetView(total: 21_600, paid: 0) { _ in }
        }
}
