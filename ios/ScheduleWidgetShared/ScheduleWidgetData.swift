// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Foundation

enum ScheduleWidgetConstants {
    static let appGroup = "group.ru.unn.unnMobile"
    static let dataKey = "schedule_cache"
    static let previousDataKey = "schedule_widget_data"
    static let kind = "ScheduleWidget"
    static let channel = "ru.bitcodersnn.unnstudenthub/schedule_widget"
    static let url = URL(string: "unnhub://schedule-widget")!
}

struct ScheduleWidgetLesson: Decodable, Identifiable {
    let title: String
    let type: String
    let auditorium: String
    let building: String
    let lecturer: String
    let start: Double
    let end: Double

    private enum CodingKeys: String, CodingKey {
        case title = "name"
        case type, auditorium, building, lecturer, start, end
    }

    var location: String {
        [auditorium, building].filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: " / ")
    }
    var id: String { "\(start)|\(end)|\(title)|\(location)" }
    var startDate: Date { Date(timeIntervalSince1970: start / 1000) }
    var endDate: Date { Date(timeIntervalSince1970: end / 1000) }
}

struct ScheduleCoverage {
    let start: Double
    let end: Double
}

struct ScheduleCacheData: Decodable {
    struct Configuration: Decodable {
        let ownerId: Int
        let ownerLabel: String
        let type: String
        let useRasp: Bool
    }

    struct Week: Decodable {
        let start: Double
        let end: Double
        let subjects: [ScheduleWidgetLesson]
    }

    struct Entry: Decodable {
        let ownerId: Int
        let type: String
        let id: String?
        let useRasp: Bool
        let schedule: Week
    }

    let version: Int
    let widget: Configuration?
    let entries: [Entry]

    var widgetData: ScheduleWidgetData? {
        guard version == 1, let widget else { return nil }
        let weeks = entries.filter {
            $0.ownerId == widget.ownerId && $0.type == widget.type &&
            $0.useRasp == widget.useRasp && $0.id == nil
        }.map(\.schedule)
        return ScheduleWidgetData(
            ownerLabel: widget.ownerLabel,
            coverage: weeks.map { ScheduleCoverage(start: $0.start, end: $0.end) },
            lessons: weeks.flatMap(\.subjects).sorted { $0.start < $1.start }
        )
    }
}

struct ScheduleWidgetData {
    let ownerLabel: String
    let coverage: [ScheduleCoverage]
    let lessons: [ScheduleWidgetLesson]

    static func read() -> ScheduleWidgetData? {
        guard let value = UserDefaults(suiteName: ScheduleWidgetConstants.appGroup)?
                .string(forKey: ScheduleWidgetConstants.dataKey),
              let bytes = value.data(using: .utf8),
              let data = try? JSONDecoder().decode(ScheduleCacheData.self, from: bytes) else { return nil }
        return data.widgetData
    }

    func covers(_ date: Date) -> Bool {
        let start = Calendar.current.startOfDay(for: date)
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return false }
        return coverage.contains {
            $0.start <= start.timeIntervalSince1970 * 1000 && $0.end >= end.timeIntervalSince1970 * 1000
        }
    }

    func today(at date: Date) -> [ScheduleWidgetLesson] {
        lessons.filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
            .sorted { $0.start < $1.start }
    }

    func remaining(at date: Date) -> [ScheduleWidgetLesson] {
        today(at: date).filter { $0.endDate > date }
    }
}
