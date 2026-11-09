// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import SwiftUI
import WidgetKit

struct ScheduleWidgetView: View {
    let entry: ScheduleEntry
    @Environment(\.widgetFamily) private var family
    private let accent = SchedulePalette.accent
    private var settings: ScheduleWidgetSettings { entry.settings }

    private var rowHeight: CGFloat {
        let base: CGFloat
        switch family {
        case .systemMedium: base = 30
        case .systemLarge: base = 58
        default: base = 42
        }
        let extraLines = (settings.showLocation ? 1 : 0) + (settings.showLecturer ? 1 : 0)
        return (base + CGFloat(extraLines) * 14) * settings.textSize.scale
    }

    private var itemSpacing: CGFloat { family == .systemMedium ? 2 : 8 }

    private func lessonCapacity(for height: CGFloat) -> Int {
        let familyLimit: Int
        switch family {
        case .systemSmall: familyLimit = 1
        case .systemMedium: familyLimit = 2
        default: familyLimit = 6
        }
        let headerHeight: CGFloat = (family == .systemMedium ? 30 : 36) * settings.textSize.scale
        let footerHeight: CGFloat = 12 * settings.textSize.scale
        let available = max(1, Int((height - headerHeight - footerHeight - 2 * itemSpacing) / (rowHeight + itemSpacing)))
        let configuredLimit = settings.maxLessons == 0 ? familyLimit : settings.maxLessons
        return min(available, familyLimit, configuredLimit)
    }

    private var remaining: [ScheduleLesson] {
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
            let capacity = lessonCapacity(for: geometry.size.height)
            VStack(alignment: .leading, spacing: itemSpacing) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Label("Расписание", systemImage: "calendar")
                            .font(textFont(13, weight: .semibold))
                            .foregroundColor(accent)
                        Spacer(minLength: 0)
                        if !remaining.isEmpty {
                            Text("\(remaining.count)")
                                .font(textFont(11, weight: .semibold))
                                .foregroundColor(accent)
                                .frame(
                                    width: family == .systemMedium ? 16 : 20,
                                    height: family == .systemMedium ? 16 : 20
                                )
                                .background(Circle().fill(accent.opacity(0.12)))
                        }
                    }
                    Text(dateLabel)
                        .font(textFont(family == .systemMedium ? 10 : 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                if remaining.isEmpty {
                    Spacer(minLength: 0)
                    Text(emptyMessage).font(textFont(13)).foregroundColor(.secondary)
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
                .font(textFont(10, weight: .medium))
                .foregroundColor(accent)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, family == .systemMedium ? 8 : 14)
        .scheduleWidgetBackground()
        .widgetURL(ScheduleNavigation.url)
    }

    private var dateLabel: String {
        return [ScheduleTime.format(entry.date, pattern: "EEE, d MMM"), entry.data?.ownerLabel ?? ""]
            .filter { !$0.isEmpty }.joined(separator: " · ")
    }

    private func lessonRow(_ lesson: ScheduleLesson) -> some View {
        let current = lesson.startDate <= entry.date && entry.date < lesson.endDate
        let compact = family == .systemMedium
        let lessonColor = SchedulePalette.subjectColor(lesson.accentColor)
        return HStack(alignment: .top, spacing: 7) {
            RoundedRectangle(cornerRadius: 2).fill(lessonColor).frame(width: 3)
            VStack(alignment: .leading, spacing: compact ? 1 : 3) {
                Text(lesson.title).font(textFont(13, weight: .semibold))
                    .lineLimit(family == .systemLarge ? 2 : 1)
                Text(current ? "Сейчас" : lesson.type)
                    .font(textFont(10)).foregroundColor(.secondary).lineLimit(1)
                if settings.showLocation && !lesson.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(lesson.location)
                        .font(textFont(10)).foregroundColor(.secondary).lineLimit(1)
                }
                if settings.showLecturer && !lesson.lecturer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(lesson.lecturer)
                        .font(textFont(10)).foregroundColor(.secondary).lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .trailing, spacing: 0) {
                Text(timeLabel(lesson.startDate)).font(textFont(12, weight: .semibold))
                Spacer(minLength: 3)
                Text(timeLabel(lesson.endDate)).font(textFont(10)).foregroundColor(.secondary)
            }
            .fixedSize(horizontal: true, vertical: false)
            .frame(maxHeight: .infinity)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, compact ? 1 : 4)
        .padding(.horizontal, 5)
        .frame(height: rowHeight, alignment: .top)
        .background(RoundedRectangle(cornerRadius: 8).fill(current ? lessonColor.opacity(0.08) : .clear))
        .accessibilityElement(children: .combine)
        .privacySensitive()
    }

    private func timeLabel(_ date: Date) -> String {
        ScheduleTime.format(date, pattern: "HH:mm")
    }

    private func textFont(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size * settings.textSize.scale, weight: weight)
    }
}

private extension View {
    func scheduleWidgetBackground() -> some View {
        modifier(ScheduleWidgetBackground())
    }
}

private struct ScheduleWidgetBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    @ViewBuilder
    func body(content: Content) -> some View {
        let color = SchedulePalette.background(for: colorScheme)
        if #available(iOSApplicationExtension 17.0, *) {
            content.containerBackground(for: .widget) { color }
        } else {
            content.background(color)
        }
    }
}

struct ScheduleWidget: Widget {
    var body: some WidgetConfiguration {
        makeConfiguration().scheduleWidgetPresentation()
    }

    private func makeConfiguration() -> some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return AppIntentConfiguration(
                kind: ScheduleConstants.widgetKind,
                intent: ScheduleWidgetConfiguration.self,
                provider: ConfigurableScheduleProvider()
            ) { entry in
                ScheduleWidgetView(entry: entry)
            }
        } else {
            return StaticConfiguration(kind: ScheduleConstants.widgetKind, provider: ScheduleProvider()) { entry in
                ScheduleWidgetView(entry: entry)
            }
        }
    }
}

private extension WidgetConfiguration {
    func scheduleWidgetPresentation() -> some WidgetConfiguration {
        configurationDisplayName("Расписание ННГУ")
            .description("Оставшиеся занятия на сегодня")
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
            .contentMarginsDisabled()
    }
}

@main
struct ScheduleWidgets: WidgetBundle {
    var body: some Widget {
        ScheduleWidget()
        if #available(iOS 16.2, *) {
            ScheduleLiveActivity()
        }
    }
}
