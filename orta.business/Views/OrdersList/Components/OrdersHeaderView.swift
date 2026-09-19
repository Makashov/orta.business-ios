//
//  OrdersHeaderView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

struct OrdersHeaderView: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            if isSearching {
                HStack(spacing: 9) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.brandAccent)

                    TextField("Номер, имя, телефон, адрес", text: $searchText)
                        .font(.system(size: 14, weight: .semibold))
                        .textFieldStyle(.plain)
                        .focused($isFocused)

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                                .frame(width: 20, height: 20)
                                .background(Circle().fill(Color.primary.opacity(0.06)))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 11)
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(Color("Card"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .strokeBorder(Color.brandAccent, lineWidth: 1.5)
                )
                .transition(.opacity.combined(with: .move(edge: .leading)))

                Button("Отмена") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSearching = false
                    }
                    searchText = ""
                }
                .font(.system(size: 13.5, weight: .semibold))
                .foregroundStyle(Color.brandAccent)
                .buttonStyle(.plain)
                .transition(.opacity)
            } else {
                Text("Заказы")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSearching = true
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 38, height: 38)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color("Card"))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color("Line"))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Поиск")
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .onChange(of: isSearching) { _, newValue in
            isFocused = newValue
        }
    }
}

#Preview("Light Mode") {
    OrdersHeaderView(searchText: .constant(""), isSearching: .constant(false))
        .appBackground()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    OrdersHeaderView(searchText: .constant(""), isSearching: .constant(false))
        .appBackground()
        .preferredColorScheme(.dark)
}

#Preview("Searching") {
    OrdersHeaderView(searchText: .constant(""), isSearching: .constant(true))
        .appBackground()
        .preferredColorScheme(.light)
}
