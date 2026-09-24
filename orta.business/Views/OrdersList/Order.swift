//
//  Order.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import Foundation

/// Raw `/api/orders` list item shape, decoded before being resolved into an `Order`
/// (which needs the matching `OrderStatus` looked up by `status` id).
struct OrderDTO: Decodable {
    struct Client: Decodable {
        let name: String
        let phone: String
    }

    struct Address: Decodable {
        let id: Int?
        let text: String
        let placeId: String?
        let lat: Double?
        let lng: Double?
    }

    let id: Int
    let number: String
    let status: Int
    let client: Client
    let address: Address
    /// Naive `"yyyy-MM-dd'T'HH:mm"` timestamp, or `nil` when not yet scheduled.
    let scheduledAt: String?
    let total: Int
}

struct Order: Identifiable, Hashable {
    let id: Int
    let sum: Int
    /// `nil` when the order has no scheduled date/time yet.
    let scheduledAt: Date?
    let address: String
    let name: String
    let phone: String
    var status: OrderStatus
    private let rawNumber: String

    var number: String { rawNumber.isEmpty ? "№ \(id)" : rawNumber }
    var displayName: String { name.isEmpty ? phone : name }

    init(
        id: Int,
        sum: Int,
        scheduledAt: Date?,
        address: String,
        name: String,
        phone: String,
        status: OrderStatus,
        number: String = ""
    ) {
        self.id = id
        self.sum = sum
        self.scheduledAt = scheduledAt
        self.address = address
        self.name = name
        self.phone = phone
        self.status = status
        self.rawNumber = number
    }

    /// - Parameter status: resolved from `dto.status` via `OrderStatusStore`.
    init(dto: OrderDTO, status: OrderStatus) {
        self.init(
            id: dto.id,
            sum: dto.total,
            scheduledAt: dto.scheduledAt.flatMap { DateFormatter.orderTimestamp.date(from: $0) },
            address: dto.address.text,
            name: dto.client.name,
            phone: dto.client.phone,
            status: status,
            number: dto.number
        )
    }

    static let sample: [Order] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        func date(_ dayOffset: Int, _ hour: Int, _ minute: Int) -> Date {
            let day = calendar.date(byAdding: .day, value: dayOffset, to: today)!
            return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)!
        }
        return [
            Order(id: 1046, sum: 9700, scheduledAt: date(1, 10, 0), address: "ул. Сатпаева 90/20", name: "Бекзат Оразов", phone: "+7 705 771 30 12", status: .new),
            Order(id: 1045, sum: 27400, scheduledAt: date(1, 9, 15), address: "мкр. Коктем-1, 12", name: "", phone: "+7 747 618 04 55", status: .new),
            Order(id: 1042, sum: 12000, scheduledAt: date(0, 14, 30), address: "ул. Абая 52, кв. 14", name: "Айгүл Серикова", phone: "+7 707 415 22 89", status: .new),
            Order(id: 1041, sum: 8500, scheduledAt: date(0, 13, 5), address: "мкр. Самал-2, 33", name: "Дмитрий Ким", phone: "+7 701 338 90 14", status: .work),
            Order(id: 1040, sum: 24000, scheduledAt: nil, address: "ул. Розыбакиева 247", name: "", phone: "+7 747 902 71 06", status: .ready),
            Order(id: 1039, sum: 6000, scheduledAt: date(0, 10, 15), address: "пр. Достык 105, кв. 7", name: "Ольга Петрова", phone: "+7 705 214 60 33", status: .done),
            Order(id: 1038, sum: 15000, scheduledAt: date(-1, 17, 20), address: "ул. Жандосова 6", name: "Сауле Абдирова", phone: "+7 708 551 47 20", status: .canceled),
            Order(id: 1037, sum: 31500, scheduledAt: nil, address: "пр. Райымбека 348Б", name: "", phone: "+7 776 120 88 45", status: .work),
            Order(id: 1036, sum: 4200, scheduledAt: date(-2, 16, 45), address: "ул. Тимирязева 42, оф. 9", name: "Ерлан Тулегенов", phone: "+7 702 663 19 77", status: .ready),
            Order(id: 1035, sum: 19800, scheduledAt: date(-4, 11, 5), address: "мкр. Аксай-3А, 18", name: "Марина Ли", phone: "+7 747 205 33 91", status: .done),
            Order(id: 1032, sum: 7300, scheduledAt: nil, address: "ул. Гоголя 86, оф. 4", name: "Асель Мухамед", phone: "+7 701 449 82 60", status: .done),
            Order(id: 1030, sum: 45000, scheduledAt: date(-9, 9, 50), address: "пр. Сейфуллина 498", name: "", phone: "+7 708 903 27 41", status: .canceled),
        ]
    }()
}
