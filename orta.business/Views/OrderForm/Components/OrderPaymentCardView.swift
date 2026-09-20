//
//  OrderPaymentCardView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

private extension PaymentMethod {
    var fill: Color { self == .cash ? Color("GreenBase") : Color("VioletBase") }
    var surface: Color { self == .cash ? Color("GreenSurface") : Color("VioletSurface") }
    var groupLabel: String { self == .cash ? "Наличные" : "QR / Kaspi" }
}

struct OrderPaymentCardView: View {
    let total: Int
    let payments: [OrderPayment]
    var canFinish: Bool = true
    var hasRemovedPayments: Bool = false
    var onRecord: () -> Void = {}
    var onFinish: () -> Void = {}
    var onRemove: (OrderPayment) -> Void = { _ in }
    var onRestore: () -> Void = {}
    var onReceipt: () -> Void = {}

    @State private var isLogExpanded = true
    @State private var pendingRemovalID: OrderPayment.ID?

    private struct MethodGroup: Identifiable {
        let label: String
        let fill: Color
        let amount: Int
        var id: String { label }
    }

    private var paid: Int { payments.reduce(0) { $0 + $1.amount } }
    private var remaining: Int { max(total - paid, 0) }
    private var isFullyPaid: Bool { total > 0 && paid >= total }
    private var isLogVisible: Bool { isFullyPaid || isLogExpanded }
    private var sortedPayments: [OrderPayment] { payments.sorted { $0.date < $1.date } }

    private var groups: [MethodGroup] {
        [PaymentMethod.cash, .kaspiQR].compactMap { representative in
            let amount = payments
                .filter { ($0.method == .cash) == (representative == .cash) }
                .reduce(0) { $0 + $1.amount }
            guard amount > 0 else { return nil }
            return MethodGroup(label: representative.groupLabel, fill: representative.fill, amount: amount)
        }
    }

    private var headline: String {
        paid > 0 ? "Остаток \(remaining.formatted()) ₸" : "Не оплачен · \(total.formatted()) ₸"
    }

    private var finishHint: String {
        paid > 0
            ? "Спишет остаток \(remaining.formatted()) ₸ как оплаченный и закроет заказ"
            : "Спишет всю сумму как оплаченную и закроет заказ"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if !payments.isEmpty {
                paidSection
                    .padding(.top, 13)
            }

            if !isFullyPaid && canFinish {
                finishButton
                    .padding(.top, 12)

                Text(finishHint)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 7)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("Card"))
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "creditcard")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text("Оплата")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.4)
                    .textCase(.uppercase)
                    .foregroundStyle(.tertiary)

                if isFullyPaid {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color("GreenBase"))
                        Text("Оплачено полностью")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color("GreenInk"))
                    }
                } else {
                    Text(headline)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }

            Spacer(minLength: 8)

            if isFullyPaid {
                Text(verbatim: "\(total.formatted()) ₸")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
            } else {
                Button(action: onRecord) {
                    Text("Записать")
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundStyle(Color("AccentInk"))
                        .padding(.horizontal, 13)
                        .frame(minHeight: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 11, style: .continuous)
                                .fill(Color("AccentBg"))
                        )
                        .opacity(remaining > 0 ? 1 : 0.5)
                }
                .buttonStyle(.plain)
                .disabled(remaining == 0)
            }
        }
    }

    // MARK: - Paid summary + history

    private var paidSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .padding(.bottom, 12)

            HStack(alignment: .firstTextBaseline) {
                Text("Внесено")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.4)
                    .textCase(.uppercase)
                    .foregroundStyle(.tertiary)
                Spacer(minLength: 8)
                Text(verbatim: "\(paid.formatted()) ₸ из \(total.formatted()) ₸")
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundStyle(isFullyPaid ? Color("GreenInk") : Color.primary.opacity(0.85))
            }

            progressBar
                .padding(.top, 8)

            VStack(spacing: 7) {
                ForEach(groups) { group in
                    HStack(spacing: 9) {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(group.fill)
                            .frame(width: 7, height: 7)
                        Text(group.label)
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundStyle(Color.primary.opacity(0.85))
                        Spacer(minLength: 8)
                        Text(verbatim: "\(group.amount.formatted()) ₸")
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(.top, 9)

            if isLogVisible {
                paymentLog
                    .padding(.top, 11)
            }

            if !isFullyPaid {
                logToggle
                    .padding(.top, 10)
            } else {
                receiptButton
                    .padding(.top, 11)
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(groups) { group in
                    Rectangle()
                        .fill(group.fill)
                        .frame(width: total > 0 ? proxy.size.width * CGFloat(group.amount) / CGFloat(total) : 0)
                }
            }
            .frame(width: proxy.size.width, alignment: .leading)
        }
        .frame(height: 6)
        .background(Color("LineSoft"))
        .clipShape(Capsule())
    }

    private var paymentLog: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .padding(.bottom, 11)

            VStack(spacing: 10) {
                ForEach(sortedPayments) { payment in
                    logRow(payment)
                }

                if hasRemovedPayments {
                    restoreButton
                }
            }
        }
    }

    private func logRow(_ payment: OrderPayment) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: payment.method.systemImage)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(payment.method.fill)
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(payment.method.surface)
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(payment.method.label)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(Color.primary.opacity(0.85))
                Text(logSubtitle(for: payment))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            if pendingRemovalID == payment.id {
                HStack(spacing: 6) {
                    Button {
                        pendingRemovalID = nil
                    } label: {
                        Text("Отмена")
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundStyle(Color.primary.opacity(0.85))
                            .padding(.horizontal, 10)
                            .frame(minHeight: 28)
                            .background(
                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                    .fill(Color("Card"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                    .strokeBorder(Color("Line"))
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        pendingRemovalID = nil
                        onRemove(payment)
                    } label: {
                        Text("Удалить")
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundStyle(Color("DangerInk"))
                            .padding(.horizontal, 10)
                            .frame(minHeight: 28)
                            .background(
                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                    .fill(Color("DangerSurface"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                    .strokeBorder(Color("DangerLine"))
                            )
                    }
                    .buttonStyle(.plain)
                }
            } else {
                HStack(spacing: 4) {
                    Text(verbatim: "\(payment.amount.formatted()) ₸")
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundStyle(.primary)

                    Button {
                        pendingRemovalID = payment.id
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.tertiary)
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Удалить платёж")
                }
            }
        }
    }

    private func logSubtitle(for payment: OrderPayment) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM, HH:mm"
        let date = formatter.string(from: payment.date)
        return payment.author.isEmpty ? date : "\(date) · \(payment.author)"
    }

    private var restoreButton: some View {
        Button(action: onRestore) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)

                Text("Платёж удалён — остаток пересчитан")
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundStyle(Color.primary.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Вернуть")
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundStyle(Color("AccentInk"))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(Color("Card2"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .strokeBorder(Color("Line"), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            )
        }
        .buttonStyle(.plain)
    }

    private var logToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isLogExpanded.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Text(isLogExpanded ? "Скрыть историю" : "История платежей · \(payments.count)")
                    .font(.system(size: 11.5, weight: .bold))
                Image(systemName: isLogExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundStyle(Color("AccentInk"))
            .frame(maxWidth: .infinity, minHeight: 34)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color("Card2"))
            )
        }
        .buttonStyle(.plain)
    }

    private var receiptButton: some View {
        Button(action: onReceipt) {
            HStack(spacing: 7) {
                Image(systemName: "doc.text")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text("Чек и квитанция")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.primary.opacity(0.85))
            }
            .frame(maxWidth: .infinity, minHeight: 38)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(Color("Card"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .strokeBorder(Color("Line"))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Finish

    private var finishButton: some View {
        Button(action: onFinish) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                Text("Завершить")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(Color("AccentLabel"))
            .frame(maxWidth: .infinity)
            .frame(minHeight: 46)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color("GreenBase"))
            )
            .shadow(color: Color("GreenBase").opacity(0.28), radius: 6, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Partially paid") {
    OrderPaymentCardView(
        total: 21_600,
        payments: [
            OrderPayment(amount: 9_000, method: .cash, author: "Асхат"),
            OrderPayment(amount: 5_400, method: .kaspiQR, author: "Айгүл"),
        ],
        hasRemovedPayments: true
    )
    .padding()
    .appBackground()
}

#Preview("Fully paid") {
    OrderPaymentCardView(
        total: 21_600,
        payments: [
            OrderPayment(amount: 14_400, method: .cash, author: "Асхат"),
            OrderPayment(amount: 7_200, method: .kaspiTransfer, author: "Айгүл"),
        ],
        canFinish: false
    )
    .padding()
    .appBackground()
    .preferredColorScheme(.dark)
}
