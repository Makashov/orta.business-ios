//
//  OrderDetailsActionBarView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

struct OrderDetailsActionBarView: View {
    var onEdit: () -> Void = {}
    var onFinish: () -> Void = {}

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onEdit) {
                Label("Редактировать", systemImage: "square.and.pencil")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(Color.brandAccent)
                    )
                    .shadow(color: Color.brandAccent.opacity(0.34), radius: 8, y: 4)
            }

            Button(action: onFinish) {
                Image(systemName: "checkmark")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Color("GreenBase"))
                    .frame(width: 56, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(Color("GreenSurface"))
                    )
            }
            .accessibilityLabel("Завершить заказ")
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
    }
}

#Preview {
    OrderDetailsActionBarView()
        .appBackground()
}
