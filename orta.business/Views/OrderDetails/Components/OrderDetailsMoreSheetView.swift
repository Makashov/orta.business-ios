//
//  OrderDetailsMoreSheetView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

struct OrderDetailsMoreSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 8) {
            row("Печать квитанции", systemImage: "printer", tint: .brandAccent, surface: Color("Bg"), ink: .primary)
            row("Дублировать заказ", systemImage: "doc.on.doc", tint: .brandAccent, surface: Color("Bg"), ink: .primary)
            row("Отменить заказ", systemImage: "xmark", tint: Color("DangerBase"), surface: Color("DangerSurface"), ink: Color("DangerInk"))

            Button("Закрыть") { dismiss() }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 46)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color("Line"), lineWidth: 1)
                )
                .padding(.top, 2)
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 12)
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }

    private func row(_ title: String, systemImage: String, tint: Color, surface: Color, ink: Color) -> some View {
        Button {
            // Action not specified yet.
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 22)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ink)
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(surface)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    Color.clear.sheet(isPresented: .constant(true)) {
        OrderDetailsMoreSheetView()
    }
}
