//
//  QuickActionsGridView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import SwiftUI

struct QuickActionItem: Identifiable {
    let id = UUID()
    let icon: String
    let tint: Color
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey?
    let spansTwoColumns: Bool

    init(icon: String, tint: Color, title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, spansTwoColumns: Bool = false) {
        self.icon = icon
        self.tint = tint
        self.title = title
        self.subtitle = subtitle
        self.spansTwoColumns = spansTwoColumns
    }

    static let homeItems: [QuickActionItem] = [
        QuickActionItem(icon: "list.bullet", tint: .blue, title: "Orders", subtitle: "21 active", spansTwoColumns: true),
        QuickActionItem(icon: "banknote", tint: .red, title: "Expenses"),
        QuickActionItem(icon: "chart.line.uptrend.xyaxis", tint: .green, title: "Statistics"),
        QuickActionItem(icon: "person.2", tint: .indigo, title: "Clients"),
        QuickActionItem(icon: "person.3", tint: .purple, title: "Users"),
        QuickActionItem(icon: "truck.box", tint: .orange, title: "Deliveries"),
        QuickActionItem(icon: "gearshape", tint: .gray, title: "Settings"),
    ]
}

/// Lays out `items` as: row 1 = one featured (2-column) tile + 2 regular tiles,
/// row 2 = 4 regular tiles. `Grid`/`GridRow` is required (not `LazyVGrid`) because
/// `.gridCellColumns()` — needed for the featured tile's column span — has no
/// effect inside `LazyVGrid`.
struct QuickActionsGridView: View {
    var items: [QuickActionItem] = QuickActionItem.homeItems
    var onSelect: (QuickActionItem) -> Void = { _ in }

    var body: some View {
        Grid(horizontalSpacing: 10, verticalSpacing: 10) {
            GridRow {
                tile(items[0])
                    .gridCellColumns(2)
                tile(items[1])
                tile(items[2])
            }
            GridRow {
                tile(items[3])
                tile(items[4])
                tile(items[5])
                tile(items[6])
            }
        }
    }

    @ViewBuilder
    private func tile(_ item: QuickActionItem) -> some View {
        Button {
            onSelect(item)
        } label: {
            if item.spansTwoColumns {
                FeaturedQuickActionTileView(item: item)
            } else {
                QuickActionTileView(item: item)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct QuickActionIconBadge: View {
    let icon: String
    let tint: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 11, style: .continuous)
            .fill(tint.opacity(0.15))
            .frame(width: 34, height: 34)
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(tint)
            )
    }
}

private struct FeaturedQuickActionTileView: View {
    let item: QuickActionItem

    var body: some View {
        HStack(spacing: 11) {
            QuickActionIconBadge(icon: item.icon, tint: item.tint)

            VStack(alignment: .leading, spacing: 1) {
                Text(item.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.primary)
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
        .frame(maxWidth: .infinity)
        .cardSurface(cornerRadius: 16)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
    }
}

private struct QuickActionTileView: View {
    let item: QuickActionItem

    var body: some View {
        VStack(spacing: 7) {
            QuickActionIconBadge(icon: item.icon, tint: item.tint)

            Text(item.title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(EdgeInsets(top: 12, leading: 2, bottom: 10, trailing: 2))
        .frame(maxWidth: .infinity)
        .cardSurface(cornerRadius: 16)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
    }
}


#Preview("Light Mode") {
    QuickActionsGridView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    QuickActionsGridView()
        .preferredColorScheme(.dark)
}
