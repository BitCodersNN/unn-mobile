// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import SwiftUI
import WidgetKit

@available(iOS 16.1, *)
struct ScheduleLockScreenWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: ScheduleConstants.lockScreenWidgetKind, provider: ScheduleProvider()) { entry in
            ScheduleLockScreenView(entry: entry)
        }
        .configurationDisplayName("Ближайшее занятие")
        .description("Текущая или ближайшая пара на сегодня: время, предмет и аудитория.")
        .supportedFamilies([.accessoryRectangular])
        .contentMarginsDisabled()
    }
}

@available(iOS 16.1, *)
struct ScheduleLockScreenView: View {
    let entry: ScheduleEntry

    var body: some View {
        HStack(spacing: 6) {
            Capsule()
                .fill(.secondary)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 0) {
                if let lesson = entry.currentOrNextLesson {
                    Text("\(ScheduleTime.format(lesson.startDate, pattern: "HH:mm")) — \(ScheduleTime.format(lesson.endDate, pattern: "HH:mm"))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    Text(lesson.title)
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                    if !lesson.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(lesson.location)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Расписание")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text(entry.emptyMessage)
                        .font(.system(size: 13))
                        .lineLimit(2)
                        .foregroundStyle(.primary)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .scheduleWidgetBackground(transparent: true)
        .widgetURL(ScheduleNavigation.url)
        .accessibilityElement(children: .combine)
        .privacySensitive()
    }
}
