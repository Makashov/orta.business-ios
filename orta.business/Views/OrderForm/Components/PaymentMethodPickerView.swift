//
//  PaymentMethodPickerView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

struct PaymentMethodPickerView: View {
    enum Tint {
        case accent, green

        var fill: Color {
            switch self {
            case .accent: Color.brandAccent
            case .green: Color("GreenBase")
            }
        }

        var surface: Color {
            switch self {
            case .accent: Color("AccentBg")
            case .green: Color("GreenSurface")
            }
        }
    }

    @Binding var selection: PaymentMethod
    var tint: Tint = .accent

    var body: some View {
        HStack(spacing: 8) {
            ForEach(PaymentMethod.allCases) { method in
                option(method)
            }
        }
    }

    private func option(_ method: PaymentMethod) -> some View {
        let isSelected = selection == method
        return Button {
            selection = method
        } label: {
            VStack(spacing: 6) {
                Image(systemName: method.systemImage)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(Color.primary.opacity(0.85))

                Text(method.label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.primary.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 66)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? tint.surface : Color("Card2"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? tint.fill : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        PaymentMethodPickerView(selection: .constant(.kaspiQR))
        PaymentMethodPickerView(selection: .constant(.cash), tint: .green)
    }
    .padding()
    .appBackground()
}
