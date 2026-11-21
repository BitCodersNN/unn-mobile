// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Foundation

enum ScheduleTime {
    static let timeZone = TimeZone(identifier: "Europe/Moscow")!

    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    static func format(_ date: Date, pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = pattern
        return formatter.string(from: date)
    }
}
