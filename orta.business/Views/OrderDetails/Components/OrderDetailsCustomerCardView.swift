//
//  OrderDetailsCustomerCardView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

struct OrderDetailsCustomerCardView: View {
    let name: String
    var subtitle: String?
    let phone: String
    var onCall: () -> Void = {}
    var onWhatsApp: () -> Void = {}

    private var initials: String {
        name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined()
    }

    var body: some View {
        OrderDetailsCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    Text(initials)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color("AccentInk"))
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(Color("AccentBg")))

                    VStack(alignment: .leading, spacing: 1) {
                        Text(name)
                            .font(.system(size: 15, weight: .bold))
                        if let subtitle {
                            Text(subtitle)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                Divider()
                    .padding(.top, 13)

                HStack(spacing: 12) {
                    Image(systemName: "phone")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .frame(width: 18)

                    VStack(alignment: .leading, spacing: 2) {
                        OrderDetailsCaption(text: "Телефон")
                        Text(phone)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .padding(.top, 13)

                HStack(spacing: 8) {
                    Button(action: onCall) {
                        Label("Позвонить", systemImage: "phone")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.brandAccent)
                            )
                    }

                    Button(action: onWhatsApp) {
                        Label("WhatsApp", image: "whatsApp")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundStyle(Color("GreenInk"))
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color("GreenSurface"))
                            )
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 11)
            }
        }
    }
}

#Preview {
    OrderDetailsCustomerCardView(name: "Дмитрий Ким", subtitle: "7 заказов · с марта 2025", phone: "+7 701 338 90 14")
        .padding()
        .appBackground()
}
