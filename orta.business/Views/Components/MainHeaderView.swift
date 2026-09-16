//
//  MainHeader.swift
//  orta.business
//
//  Created by Nurbol Makashov on 15.09.2026.
//

import SwiftUI

struct MainHeaderView: View {
    @State private var searchText = ""
    var onNotificationsTap: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.tertiary)

                TextField("Search orders, clients", text: $searchText)
                    .font(.system(size: 14, weight: .medium))
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 13)
            .frame(height: 42)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color.primary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.1))
            )

            Button(action: onNotificationsTap) {
                Image(systemName: "bell")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.primary.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.1))
                    )
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(.red)
                            .frame(width: 7, height: 7)
                            .overlay(Circle().strokeBorder(.background, lineWidth: 1.5))
                            .offset(x: -6, y: 6)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Notifications")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.background)
    }
}

extension View {
    func mainHeader() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .safeAreaInset(edge: .top, spacing: 0) {
                MainHeaderView()
            }
    }
}

#Preview {
    MainHeaderView()
}
