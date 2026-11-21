// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Foundation

struct ScheduleSnapshot: Decodable {
    let version: Int
    let ownerLabel: String
    let updatedAt: Double
    let validFrom: Double
    let validUntil: Double
    let lessons: [ScheduleLesson]

    static let schemaVersion = 2

    static func decode(_ value: String) -> ScheduleSnapshot? {
        guard let bytes = value.data(using: .utf8),
              let data = try? JSONDecoder().decode(Self.self, from: bytes),
              data.version == schemaVersion else { return nil }
        return data
    }

    func covers(_ date: Date) -> Bool {
        let start = ScheduleTime.calendar.startOfDay(for: date)
        guard let end = ScheduleTime.calendar.date(byAdding: .day, value: 1, to: start) else { return false }
        return validFrom <= start.timeIntervalSince1970 * 1000 && validUntil >= end.timeIntervalSince1970 * 1000
    }

    func today(at date: Date) -> [ScheduleLesson] {
        lessons.filter { ScheduleTime.calendar.isDate($0.startDate, inSameDayAs: date) }
            .sorted { $0.start < $1.start }
    }

    func remaining(at date: Date) -> [ScheduleLesson] {
        today(at: date).filter { $0.endDate > date }
    }
}
