//
//  RecentOrdersSectionView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import SwiftUI

struct StatusColor {
    let fill: Color
    let ink: Color
    let surface: Color
}

enum RecentOrderStatus {
    case created, inProgress, readyForPickup, completed, cancelled

    var color: StatusColor {
        switch self {
            case .created: StatusColor(
                fill: Color("Amber"),
                ink: Color("AmberInk"),
                surface: Color("AmberSurface")
            )
            case .inProgress: StatusColor(
                fill: Color("AccentColor"),
                ink: Color("AccentInk"),
                surface: Color("AccentBg")
            )
            case .readyForPickup: StatusColor(
                fill: Color("Teal"),
                ink: Color("TealInk"),
                surface: Color("TealSurface")
            )
            case .completed: StatusColor(
                fill: Color("Green"),
                ink: Color("GreenInk"),
                surface: Color("GreenSurface")
            )
            case .cancelled: StatusColor(
                fill: Color("Slate"),
                ink: Color("SlateInk"),
                surface: Color("SlateSurface")
            )
        }
    }

    var label: LocalizedStringKey {
        switch self {
        case .created: "Created"
        case .inProgress: "In progress"
        case .readyForPickup: "Ready for pickup"
        case .completed: "Completed"
        case .cancelled: "Cancelled"
        }
    }
}

struct RecentOrderItem: Identifiable {
    let id = UUID()
    let number: String
    let status: RecentOrderStatus
    let customerName: String
    let address: String?
    let time: String
    let amount: Int

    static let sampleOrders: [RecentOrderItem] = [
        RecentOrderItem(number: "№ 1042", status: .created, customerName: "Айгүл Серикова", address: "ул. Абая 52, кв. 14", time: "14:30", amount: 12_000),
        RecentOrderItem(number: "№ 1041", status: .inProgress, customerName: "Дмитрий Ким", address: "мкр. Самал-2, 33", time: "13:05", amount: 8_500),
        RecentOrderItem(number: "№ 1040", status: .readyForPickup, customerName: "Нұрлан Жаксылык", address: "ул. Розыбакиева 247", time: "11:40", amount: 24_000),
        RecentOrderItem(number: "№ 1039", status: .completed, customerName: "Ольга Петрова", address: "пр. Достык 105, кв. 7", time: "10:15", amount: 6_000),
        RecentOrderItem(number: "№ 1038", status: .cancelled, customerName: "Сауле Абдирова", address: "ул. Жандосова 6", time: "09:20", amount: 15_000),
    ]
}

struct RecentOrdersSectionView: View {
    var orders: [RecentOrderItem] = RecentOrderItem.sampleOrders
    var currencySymbol: String = "₸"
    var onSeeAll: () -> Void = {}
    var onSelect: (RecentOrderItem) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Recent orders")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                Spacer()
                Button(action: onSeeAll) {
                    Text("See all")
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 8) {
                ForEach(orders) { order in
                    Button {
                        onSelect(order)
                    } label: {
                        RecentOrderRowView(order: order, currencySymbol: currencySymbol)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct RecentOrderRowView: View {
    let order: RecentOrderItem
    let currencySymbol: String

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(order.status.color.fill)
                .frame(width: 3)
                .frame(maxHeight: .infinity)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 7) {
                    Text(order.number)
                        .font(.system(size: 13.5, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(order.status.label)
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundStyle(order.status.color.ink)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(order.status.color.surface)
                        )
                }

                Text(order.customerName)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                if let address = order.address {
                    Text(verbatim: "\(address) · \(order.time)")
                        .font(.system(size: 11.5))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Text(verbatim: "\(order.amount.formatted()) \(currencySymbol)")
                .font(.system(size: 13.5, weight: .bold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(13)
        .cardSurface(cornerRadius: 15)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
    }
}

#Preview("Light Mode") {
    RecentOrdersSectionView()
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    RecentOrdersSectionView()
        .padding()
        .preferredColorScheme(.dark)
}
