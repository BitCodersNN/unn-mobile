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
                .activityBackgroundTint(Color(UIColor.secondarySystemBackground))
                .activitySystemActionForegroundColor(.primary)
                .widgetURL(ScheduleWidgetConstants.url)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    ScheduleLiveActivityView(context: context)
                }
            } compactLeading: {
                Image(systemName: "calendar")
                    .foregroundStyle(.teal)
            } compactTrailing: {
                ScheduleActivityCountdown(context: context)
                    .font(.caption.monospacedDigit())
                    .frame(width: 54)
            } minimal: {
                Image(systemName: "calendar")
            }
            .widgetURL(ScheduleWidgetConstants.url)
            .keylineTint(.teal)
        }
    }
}

@available(iOS 16.2, *)
private struct ScheduleLiveActivityView: View {
    let context: ActivityViewContext<ScheduleActivityAttributes>
    private let accent = Color(red: 0.27, green: 0.52, blue: 0.50)
    private var started: Bool { context.isStale || Date() >= context.attributes.start }

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
                Text(started ? "Осталось" : "До начала")
                ScheduleActivityCountdown(context: context).monospacedDigit()
                Spacer(minLength: 8)
                Text(context.attributes.end, style: .time).foregroundStyle(.secondary)
            }
            .font(.subheadline)
            ProgressView(timerInterval: context.attributes.start...context.attributes.end,
                         countsDown: false)
                .labelsHidden().tint(accent)
        }
        .padding(14)
        .privacySensitive()
    }
}

@available(iOS 16.2, *)
private struct ScheduleActivityCountdown: View {
    let context: ActivityViewContext<ScheduleActivityAttributes>

    var body: some View {
        let attributes = context.attributes
        let started = context.isStale || Date() >= attributes.start
        Text(timerInterval: started ? attributes.start...attributes.end : attributes.noticeStart...attributes.start,
             countsDown: true)
    }
}
