// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Foundation

struct ScheduleSnapshot {
    let ownerLabel: String
    let validFrom: Double
    let validUntil: Double
    let lessons: [ScheduleLesson]

    func covers(_ date: Date) -> Bool {
        let start = ScheduleTime.calendar.startOfDay(for: date)
        guard let end = ScheduleTime.calendar.date(byAdding: .day, value: 1, to: start) else { return false }
        return validFrom <= start.timeIntervalSince1970 * 1000 && validUntil >= end.timeIntervalSince1970 * 1000
    }

    func today(at date: Date) -> [ScheduleLesson] {
        lessons.filter { ScheduleTime.calendar.isDate($0.startDate, inSameDayAs: date) }
    }

    func remaining(at date: Date) -> [ScheduleLesson] {
        today(at: date).filter { $0.endDate > date }
    }
}

struct ScheduleCacheData: Decodable {
    struct Configuration: Decodable {
        let ownerId: Int
        let ownerLabel: String
        let type: String
        let useRasp: Bool
    }

    struct Entry: Decodable {
        let ownerId: Int
        let type: String
        let id: String?
        let useRasp: Bool
        let schedule: Week
    }

    struct Week: Decodable {
        let start: Double
        let end: Double
        let subjects: [Subject]
    }

    struct Subject: Decodable {
        let name: String
        let type: String
        let auditorium: String
        let building: String
        let lecturer: String
        let start: Double
        let end: Double

        func lesson(accentColor: UInt32?, typeKey: String?) -> ScheduleLesson {
            ScheduleLesson(
                title: name, type: type,
                location: [auditorium, building]
                    .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                    .joined(separator: " / "),
                lecturer: lecturer, start: start, end: end,
                accentColor: accentColor, typeKey: typeKey
            )
        }
    }

    let version: Int
    let widget: Configuration?
    let entries: [Entry]
    let subjectColors: [String: UInt32]?
    let subjectTypeKeys: [String: String]?

    static func decode(_ value: String) -> Self? {
        guard let bytes = value.data(using: .utf8),
              let cache = try? JSONDecoder().decode(Self.self, from: bytes),
              cache.version == 1 else { return nil }
        return cache
    }

    func snapshot(at now: Date = Date()) -> ScheduleSnapshot? {
        guard let widget else { return nil }
        let calendar = ScheduleTime.calendar
        let today = calendar.startOfDay(for: now)
        let daysSinceMonday = (calendar.component(.weekday, from: today) + 5) % 7
        guard let start = calendar.date(byAdding: .day, value: -daysSinceMonday, to: today),
              let end = calendar.date(byAdding: .day, value: 14, to: start) else { return nil }
        let from = start.timeIntervalSince1970 * 1000
        let until = end.timeIntervalSince1970 * 1000
        let weeks = entries.filter {
            $0.ownerId == widget.ownerId && $0.type == widget.type &&
            $0.useRasp == widget.useRasp && $0.id == nil &&
            $0.schedule.start >= from && $0.schedule.end <= until
        }.map(\.schedule).sorted { $0.start < $1.start }
        guard let first = weeks.first, let last = weeks.last else { return nil }
        return ScheduleSnapshot(
            ownerLabel: widget.ownerLabel,
            validFrom: first.start, validUntil: last.end,
            lessons: weeks.flatMap(\.subjects).map {
                $0.lesson(accentColor: subjectColors?[$0.type], typeKey: subjectTypeKeys?[$0.type])
            }
                .sorted { $0.start < $1.start }
        )
    }
}
