// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import SwiftUI
import WidgetKit

struct ScheduleEntry: TimelineEntry {
    let date: Date
    let data: ScheduleWidgetData?
}

struct ScheduleProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScheduleEntry {
        let day = Calendar.current.startOfDay(for: Date())
        let first = day.addingTimeInterval(10 * 3600)
        let second = day.addingTimeInterval(12 * 3600)
        let data = ScheduleWidgetData(
            version: 1, ownerLabel: "Ваше расписание", updatedAt: day.timeIntervalSince1970 * 1000,
            validFrom: day.timeIntervalSince1970 * 1000,
            validUntil: day.addingTimeInterval(86400).timeIntervalSince1970 * 1000,
            lessons: [
                ScheduleWidgetLesson(title: "Разработка мобильных приложений", type: "Лекция", location: "301 / 2", lecturer: "", start: first.timeIntervalSince1970 * 1000, end: first.addingTimeInterval(5400).timeIntervalSince1970 * 1000),
                ScheduleWidgetLesson(title: "Программная инженерия", type: "Практика", location: "412 / 2", lecturer: "", start: second.timeIntervalSince1970 * 1000, end: second.addingTimeInterval(5400).timeIntervalSince1970 * 1000)
            ])
        return ScheduleEntry(date: first, data: data)
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : ScheduleEntry(date: Date(), data: ScheduleWidgetData.read()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> Void) {
        let now = Date()
        let data = ScheduleWidgetData.read()
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: now)
        let days = (1...14).compactMap { calendar.date(byAdding: .day, value: $0, to: midnight) }
        let boundaries = data?.lessons.flatMap { [$0.startDate, $0.endDate] } ?? []
        let dates = Array(Set([now] + days + boundaries.filter { $0 > now })).sorted().prefix(64)
        let entries = dates.map { ScheduleEntry(date: $0, data: data) }
        completion(Timeline(entries: entries, policy: .after((dates.last ?? now).addingTimeInterval(60))))
    }
}

struct ScheduleWidgetView: View {
    let entry: ScheduleEntry
    @Environment(\.widgetFamily) private var family
    private let accent = Color(red: 0, green: 0.54, blue: 0.50)

    private var rowHeight: CGFloat {
        switch family {
        case .systemMedium: return 32
        case .systemLarge: return 48
        default: return 40
        }
    }

    private var itemSpacing: CGFloat { family == .systemMedium ? 6 : 8 }

    private var remaining: [ScheduleWidgetLesson] {
        guard entry.data?.covers(entry.date) == true else { return [] }
        return entry.data?.remaining(at: entry.date) ?? []
    }

    private var emptyMessage: String {
        guard let data = entry.data else { return "Откройте приложение и войдите в аккаунт" }
        guard data.covers(entry.date) else { return "Обновите расписание в приложении" }
        return data.today(at: entry.date).isEmpty ? "Сегодня занятий нет" : "На сегодня занятий больше нет"
    }

    var body: some View {
        GeometryReader { geometry in
            let headerAndFooterHeight: CGFloat = family == .systemMedium ? 60 : 64
            let capacity = family == .systemSmall ? 1 :
                max(1, min(6, Int((geometry.size.height - headerAndFooterHeight) / (rowHeight + itemSpacing))))
            VStack(alignment: .leading, spacing: itemSpacing) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Label("Расписание", systemImage: "calendar")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(accent)
                        Spacer(minLength: 0)
                        if !remaining.isEmpty {
                            Text("\(remaining.count)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(accent)
                                .frame(width: 20, height: 20)
                                .background(Circle().fill(accent.opacity(0.12)))
                        }
                    }
                    Text(dateLabel)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                if remaining.isEmpty {
                    Spacer(minLength: 0)
                    Text(emptyMessage).font(.system(size: 13)).foregroundColor(.secondary)
                    Spacer(minLength: 0)
                } else {
                    ForEach(remaining.prefix(capacity)) { lesson in
                        lessonRow(lesson)
                    }
                    Spacer(minLength: 0)
                }
                HStack(spacing: 4) {
                    Text(remaining.count > capacity ? "Ещё \(remaining.count - capacity) · открыть" : "Открыть расписание")
                        .lineLimit(1).minimumScaleFactor(0.8)
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.up.right")
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(accent)
            }
        }
        .padding(14)
        .scheduleWidgetBackground()
        .widgetURL(ScheduleWidgetConstants.url)
    }

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEE, d MMM"
        return [formatter.string(from: entry.date), entry.data?.ownerLabel ?? ""]
            .filter { !$0.isEmpty }.joined(separator: " · ")
    }

    private func lessonRow(_ lesson: ScheduleWidgetLesson) -> some View {
        let current = lesson.startDate <= entry.date && entry.date < lesson.endDate
        let compact = family == .systemMedium
        return HStack(alignment: .top, spacing: 7) {
            RoundedRectangle(cornerRadius: 2).fill(accent).frame(width: 3)
            VStack(alignment: .leading, spacing: compact ? 2 : 3) {
                Text(lesson.title).font(.system(size: 13, weight: .semibold))
                    .lineLimit(family == .systemLarge ? 2 : 1)
                Text([current ? "Сейчас" : lesson.type, lesson.location].filter { !$0.isEmpty }.joined(separator: " · "))
                    .font(.system(size: 10)).foregroundColor(.secondary).lineLimit(1)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: compact ? 2 : 3) {
                Text(timeLabel(lesson.startDate)).font(.system(size: 12, weight: .semibold))
                Text(timeLabel(lesson.endDate)).font(.system(size: 10)).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, compact ? 1 : 4)
        .padding(.horizontal, 5)
        .frame(height: rowHeight)
        .background(RoundedRectangle(cornerRadius: 8).fill(current ? accent.opacity(0.08) : .clear))
        .accessibilityElement(children: .combine)
        .privacySensitive()
    }

    private func timeLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

private extension View {
    @ViewBuilder
    func scheduleWidgetBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(for: .widget) { Color(UIColor.secondarySystemBackground) }
        } else {
            background(Color(UIColor.secondarySystemBackground))
        }
    }
}

@main
struct ScheduleWidget: Widget {
    private var configuration: some WidgetConfiguration {
        StaticConfiguration(kind: ScheduleWidgetConstants.kind, provider: ScheduleProvider()) { entry in
            ScheduleWidgetView(entry: entry)
        }
        .configurationDisplayName("Расписание ННГУ")
        .description("Оставшиеся занятия на сегодня")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }

    var body: some WidgetConfiguration {
        configuration.contentMarginsDisabled()
    }
}
