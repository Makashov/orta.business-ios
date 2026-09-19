//
//  OrderDatePreset.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import Foundation

enum OrderDatePreset: String, CaseIterable, Identifiable {
    case all, today, tomorrow, yesterday, week, lastWeek, month, custom

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: "Всё время"
        case .today: "Сегодня"
        case .tomorrow: "Завтра"
        case .yesterday: "Вчера"
        case .week: "Эта неделя"
        case .lastWeek: "Прошлая неделя"
        case .month: "Этот месяц"
        case .custom: "Свой период"
        }
    }

    /// Inclusive day range for this preset, anchored to `referenceDate`.
    /// `nil` for either bound means "unbounded" (`.all` and `.custom` are resolved by the caller).
    func range(referenceDate: Date, calendar: Calendar) -> (from: Date?, to: Date?) {
        let today = calendar.startOfDay(for: referenceDate)
        func addingDays(_ value: Int, to date: Date) -> Date {
            calendar.date(byAdding: .day, value: value, to: date)!
        }
        // Monday = 0 ... Sunday = 6
        let weekday = (calendar.component(.weekday, from: today) + 5) % 7

        switch self {
        case .all, .custom:
            return (nil, nil)
        case .today:
            return (today, today)
        case .tomorrow:
            let d = addingDays(1, to: today)
            return (d, d)
        case .yesterday:
            let d = addingDays(-1, to: today)
            return (d, d)
        case .week:
            return (addingDays(-weekday, to: today), addingDays(6 - weekday, to: today))
        case .lastWeek:
            return (addingDays(-weekday - 7, to: today), addingDays(-weekday - 1, to: today))
        case .month:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
            let end = addingDays(-1, to: calendar.date(byAdding: .month, value: 1, to: start)!)
            return (start, end)
        }
    }
}
