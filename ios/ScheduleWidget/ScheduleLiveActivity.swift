// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import ActivityKit
import SwiftUI
import WidgetKit

@available(iOS 16.2, *)
struct ScheduleLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ScheduleActivityAttributes.self) { context in
            ScheduleLiveActivityView(context: context)
                .activitySystemActionForegroundColor(.primary)
                .widgetURL(ScheduleWidgetConstants.url)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    ScheduleLiveActivityView(context: context)
                }
            } compactLeading: {
                Image(systemName: "calendar")
                    .foregroundStyle(ScheduleWidgetPalette.subjectColor(context.attributes.accentColor))
            } compactTrailing: {
                ScheduleActivityCountdown(context: context)
                    .font(.caption.monospacedDigit())
                    .frame(width: 54)
            } minimal: {
                Image(systemName: "calendar")
            }
            .widgetURL(ScheduleWidgetConstants.url)
            .keylineTint(ScheduleWidgetPalette.subjectColor(context.attributes.accentColor))
        }
    }
}

@available(iOS 16.2, *)
private struct ScheduleLiveActivityView: View {
    let context: ActivityViewContext<ScheduleActivityAttributes>
    @Environment(\.colorScheme) private var colorScheme
    private var accent: Color { ScheduleWidgetPalette.subjectColor(context.attributes.accentColor) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(context.attributes.title).font(.headline).lineLimit(2)
                Spacer(minLength: 8)
                Text(context.attributes.type).font(.caption).foregroundStyle(.secondary)
            }
            if !context.attributes.location.isEmpty {
                Label(context.attributes.location, systemImage: "mappin.and.ellipse")
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            HStack {
                Text(context.lessonHasStarted ? "Осталось" : "До начала")
                ScheduleActivityCountdown(context: context).monospacedDigit()
                Spacer(minLength: 8)
                Text(context.attributes.end, style: .time).foregroundStyle(.secondary)
            }
            .font(.subheadline)
            ProgressView(timerInterval: context.lessonInterval, countsDown: false)
                .progressViewStyle(.linear)
                .labelsHidden()
                .tint(accent)
        }
        .padding(14)
        .activityBackgroundTint(ScheduleWidgetPalette.background(for: colorScheme))
        .privacySensitive()
    }
}

@available(iOS 16.2, *)
private struct ScheduleActivityCountdown: View {
    let context: ActivityViewContext<ScheduleActivityAttributes>

    var body: some View {
        Text(timerInterval: context.lessonInterval, countsDown: true)
    }
}

@available(iOS 16.2, *)
private extension ActivityViewContext where Attributes == ScheduleActivityAttributes {
    var lessonHasStarted: Bool { isStale || Date() >= attributes.start }

    var lessonInterval: ClosedRange<Date> {
        if lessonHasStarted || attributes.noticeStart >= attributes.start {
            return attributes.start...attributes.end
        }
        return attributes.noticeStart...attributes.start
    }
}
