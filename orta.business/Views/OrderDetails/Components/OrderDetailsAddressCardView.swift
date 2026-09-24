//
//  OrderDetailsAddressCardView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

/// Shown only when the order's address has coordinates — see `OrderDetailsView`, which
/// hides this whole card otherwise (an address typed by hand has no coordinates to link out to).
struct OrderDetailsAddressCardView: View {
    let address: String
    var note: String?
    let lat: Double
    let lng: Double
    var onOpenMaps: () -> Void = {}

    @Environment(\.openURL) private var openURL

    private var twoGISURL: URL? { ContactLinks.twoGIS(lat: lat, lng: lng) }

    var body: some View {
        OrderDetailsCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "mappin")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .frame(width: 18)
                        .padding(.top, 2)

                    VStack(alignment: .leading, spacing: 3) {
                        OrderDetailsCaption(text: "Адрес")
                        Text(address)
                            .font(.system(size: 15, weight: .medium))
                        if let note {
                            Text(note)
                                .font(.system(size: 11.5, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                HStack(spacing: 8) {
                    mapButton("На карте", systemImage: "mappin", tint: .brandAccent, action: onOpenMaps)
                    if let twoGISURL {
                        mapButton("2ГИС", systemImage: "arrow.triangle.turn.up.right.diamond", tint: Color("TealInk")) {
                            openURL(twoGISURL)
                        }
                    }
                }
                .padding(.top, 11)
            }
        }
    }

    private func mapButton(_ title: String, systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, minHeight: 46)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color("Bg"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color("Line"), lineWidth: 1)
                )
                .tint(tint)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OrderDetailsAddressCardView(
        address: "мкр. Самал-2, 33, кв. 12",
        note: "Подъезд 2, код 1244, 5 этаж",
        lat: 43.222,
        lng: 76.851
    )
    .padding()
    .appBackground()
}
