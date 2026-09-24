//
//  OrderPaymentSheetView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

/// "Запись оплаты": record a full or partial payment against the remaining balance.
struct OrderPaymentSheetView: View {
    private enum Mode {
        case full, partial
    }

    let remaining: Int
    var onSave: (Int, PaymentMethod) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var mode: Mode = .full
    @State private var amount: Int
    @State private var method: PaymentMethod = .kaspiQR

    init(remaining: Int, onSave: @escaping (Int, PaymentMethod) -> Void) {
        self.remaining = remaining
        self.onSave = onSave
        _amount = State(initialValue: remaining)
    }

    private var canSave: Bool { amount > 0 && amount <= remaining }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Text("Запись оплаты")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.primary)

                Spacer()

                closeButton
            }

            HStack(spacing: 7) {
                modeButton(.full, title: "Полная оплата")
                modeButton(.partial, title: "Частичная")
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color("Card2"))
            )
            .padding(.top, 14)

            VStack(alignment: .leading, spacing: 3) {
                Text("Сумма")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.4)
                    .textCase(.uppercase)
                    .foregroundStyle(.tertiary)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    TextField("0", value: $amount, format: .number)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.primary)
#if os(iOS)
                        .keyboardType(.numberPad)                
#endif
                        .disabled(mode == .full)

                    Text("₸")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color("Card2"))
            )
            .padding(.top, 14)

            Text("Способ оплаты")
                .font(.system(size: 10, weight: .bold))
                .tracking(0.4)
                .textCase(.uppercase)
                .foregroundStyle(.tertiary)
                .padding(.top, 16)

            PaymentMethodPickerView(selection: $method)
                .padding(.top, 9)

            Button {
                onSave(amount, method)
                dismiss()
            } label: {
                Text("Записать \(amount.formatted()) ₸")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color("AccentLabel"))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(canSave ? Color.brandAccent : Color.brandAccent.opacity(0.4))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canSave)
            .padding(.top, 18)
        }
        .padding(.horizontal, 16)
        .padding(.top, 22)
        .padding(.bottom, 16)
        .onChange(of: amount) { _, newValue in
            if newValue > remaining { amount = remaining }
            if newValue < 0 { amount = 0 }
        }
        .fittedSheetDetent()
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
    }

    private var closeButton: some View {
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

    private func modeButton(_ candidate: Mode, title: String) -> some View {
        let isActive = mode == candidate
        return Button {
            mode = candidate
            amount = candidate == .full ? remaining : 0
        } label: {
            Text(title)
                .font(.system(size: 12.5, weight: .bold))
                .foregroundStyle(Color.primary.opacity(0.85))
                .frame(maxWidth: .infinity, minHeight: 38)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isActive ? Color("Card") : Color.clear)
                        .shadow(color: .black.opacity(isActive ? 0.08 : 0), radius: 2, y: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            OrderPaymentSheetView(remaining: 21_600) { _, _ in }
        }
}
