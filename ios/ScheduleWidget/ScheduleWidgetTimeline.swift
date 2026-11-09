// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import WidgetKit
import Foundation

struct ScheduleEntry: TimelineEntry {
    let date: Date
    let data: ScheduleSnapshot?
    let settings: ScheduleWidgetSettings
}

enum ScheduleWidgetTimeline {
    static func placeholder(settings: ScheduleWidgetSettings = ScheduleWidgetSettings()) -> ScheduleEntry {
        let day = ScheduleTime.calendar.startOfDay(for: Date())
        let first = day.addingTimeInterval(10 * 3600)
        let second = day.addingTimeInterval(12 * 3600)
        let data = ScheduleSnapshot(
            version: ScheduleSnapshot.schemaVersion, ownerLabel: "Ваше расписание", updatedAt: day.timeIntervalSince1970 * 1000,
            validFrom: day.timeIntervalSince1970 * 1000,
            validUntil: day.addingTimeInterval(86400).timeIntervalSince1970 * 1000,
            lessons: [
                ScheduleLesson(title: "Разработка мобильных приложений", type: "Лекция", location: "301 / 2", lecturer: "Преподаватель", start: first.timeIntervalSince1970 * 1000, end: first.addingTimeInterval(5400).timeIntervalSince1970 * 1000, accentColor: nil),
                ScheduleLesson(title: "Программная инженерия", type: "Практика", location: "412 / 2", lecturer: "Преподаватель", start: second.timeIntervalSince1970 * 1000, end: second.addingTimeInterval(5400).timeIntervalSince1970 * 1000, accentColor: nil)
            ])
        return ScheduleEntry(date: first, data: data, settings: settings)
    }

    static func snapshot(isPreview: Bool, settings: ScheduleWidgetSettings = ScheduleWidgetSettings()) -> ScheduleEntry {
        isPreview ? placeholder(settings: settings)
            : ScheduleEntry(date: Date(), data: ScheduleSnapshotProvider().read(), settings: settings)
    }

    static func timeline(settings: ScheduleWidgetSettings = ScheduleWidgetSettings()) -> Timeline<ScheduleEntry> {
        let now = Date()
        let data = ScheduleSnapshotProvider().read()
        let calendar = ScheduleTime.calendar
        let midnight = calendar.startOfDay(for: now)
        let days = (1...14).compactMap { calendar.date(byAdding: .day, value: $0, to: midnight) }
        let boundaries = data?.lessons.flatMap { [$0.startDate, $0.endDate] } ?? []
        let dates = Array(Set([now] + days + boundaries.filter { $0 > now })).sorted().prefix(64)
        let entries = dates.map { ScheduleEntry(date: $0, data: data, settings: settings) }
        return Timeline(entries: entries, policy: .after((dates.last ?? now).addingTimeInterval(60)))
    }
}

struct ScheduleProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleWidgetTimeline.placeholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> Void) {
        completion(ScheduleWidgetTimeline.snapshot(isPreview: context.isPreview))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> Void) {
        completion(ScheduleWidgetTimeline.timeline())
    }
}
