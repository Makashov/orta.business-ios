//
//  Order.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

struct StatusColor {
    let fill: Color
    let ink: Color
    let surface: Color
}

enum OrderStatus: String, CaseIterable {
    case new, work, ready, done, canceled

    var label: String {
        switch self {
        case .new: "Создан"
        case .work: "В работе"
        case .ready: "Готов к выдаче"
        case .done: "Завершён"
        case .canceled: "Отменён"
        }
    }

    var color: StatusColor {
        switch self {
        case .new: StatusColor(
            fill: Color("AmberBase"),
            ink: Color("AmberInk"),
            surface: Color("AmberSurface")
        )
        case .work: StatusColor(
            fill: Color("AccentColor"),
            ink: Color("AccentInk"),
            surface: Color("AccentBg")
        )
        case .ready: StatusColor(
            fill: Color("TealBase"),
            ink: Color("TealInk"),
            surface: Color("TealSurface")
        )
        case .done: StatusColor(
            fill: Color("GreenBase"),
            ink: Color("GreenInk"),
            surface: Color("GreenSurface")
        )
        case .canceled: StatusColor(
            fill: Color("SlateBase"),
            ink: Color("SlateInk"),
            surface: Color("SlateSurface")
        )
        }
    }
}

struct Order: Identifiable {
    let id: Int
    let sum: Int
    let date: Date
    let address: String
    let name: String
    let phone: String
    var status: OrderStatus

    var number: String { "№ \(id)" }
    var displayName: String { name.isEmpty ? phone : name }

    static let sample: [Order] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        func date(_ dayOffset: Int, _ hour: Int, _ minute: Int) -> Date {
            let day = calendar.date(byAdding: .day, value: dayOffset, to: today)!
            return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)!
        }
        return [
            Order(id: 1046, sum: 9700, date: date(1, 10, 0), address: "ул. Сатпаева 90/20", name: "Бекзат Оразов", phone: "+7 705 771 30 12", status: .new),
            Order(id: 1045, sum: 27400, date: date(1, 9, 15), address: "мкр. Коктем-1, 12", name: "", phone: "+7 747 618 04 55", status: .new),
            Order(id: 1042, sum: 12000, date: date(0, 14, 30), address: "ул. Абая 52, кв. 14", name: "Айгүл Серикова", phone: "+7 707 415 22 89", status: .new),
            Order(id: 1041, sum: 8500, date: date(0, 13, 5), address: "мкр. Самал-2, 33", name: "Дмитрий Ким", phone: "+7 701 338 90 14", status: .work),
            Order(id: 1040, sum: 24000, date: date(0, 11, 40), address: "ул. Розыбакиева 247", name: "", phone: "+7 747 902 71 06", status: .ready),
            Order(id: 1039, sum: 6000, date: date(0, 10, 15), address: "пр. Достык 105, кв. 7", name: "Ольга Петрова", phone: "+7 705 214 60 33", status: .done),
            Order(id: 1038, sum: 15000, date: date(-1, 17, 20), address: "ул. Жандосова 6", name: "Сауле Абдирова", phone: "+7 708 551 47 20", status: .canceled),
            Order(id: 1037, sum: 31500, date: date(-1, 12, 10), address: "пр. Райымбека 348Б", name: "", phone: "+7 776 120 88 45", status: .work),
            Order(id: 1036, sum: 4200, date: date(-2, 16, 45), address: "ул. Тимирязева 42, оф. 9", name: "Ерлан Тулегенов", phone: "+7 702 663 19 77", status: .ready),
            Order(id: 1035, sum: 19800, date: date(-4, 11, 5), address: "мкр. Аксай-3А, 18", name: "Марина Ли", phone: "+7 747 205 33 91", status: .done),
            Order(id: 1032, sum: 7300, date: date(-7, 15, 30), address: "ул. Гоголя 86, оф. 4", name: "Асель Мухамед", phone: "+7 701 449 82 60", status: .done),
            Order(id: 1030, sum: 45000, date: date(-9, 9, 50), address: "пр. Сейфуллина 498", name: "", phone: "+7 708 903 27 41", status: .canceled),
        ]
    }()
}
