// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Foundation

enum ScheduleWidgetConstants {
    static let appGroup = "group.ru.unn.unnMobile"
    static let dataKey = "schedule_widget_data"
    static let kind = "ScheduleWidget"
    static let channel = "ru.bitcodersnn.unnstudenthub/schedule_widget"
    static let url = URL(string: "unnhub://schedule-widget")!
}

struct ScheduleWidgetLesson: Decodable, Identifiable {
    let title: String
    let type: String
    let location: String
    let lecturer: String
    let start: Double
    let end: Double

    var id: String { "\(start)|\(end)|\(title)|\(location)" }
    var startDate: Date { Date(timeIntervalSince1970: start / 1000) }
    var endDate: Date { Date(timeIntervalSince1970: end / 1000) }
}

struct ScheduleWidgetData: Decodable {
    let version: Int
    let ownerLabel: String
    let updatedAt: Double
    let validFrom: Double
    let validUntil: Double
    let lessons: [ScheduleWidgetLesson]

    static func read() -> ScheduleWidgetData? {
        guard let value = UserDefaults(suiteName: ScheduleWidgetConstants.appGroup)?
                .string(forKey: ScheduleWidgetConstants.dataKey),
              let bytes = value.data(using: .utf8),
              let data = try? JSONDecoder().decode(ScheduleWidgetData.self, from: bytes),
              data.version == 1 else { return nil }
        return data
    }

    func covers(_ date: Date) -> Bool {
        let start = Calendar.current.startOfDay(for: date)
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return false }
        return validFrom <= start.timeIntervalSince1970 * 1000 && validUntil >= end.timeIntervalSince1970 * 1000
    }

    func today(at date: Date) -> [ScheduleWidgetLesson] {
        lessons.filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
            .sorted { $0.start < $1.start }
    }

    func remaining(at date: Date) -> [ScheduleWidgetLesson] {
        today(at: date).filter { $0.endDate > date }
    }
}
