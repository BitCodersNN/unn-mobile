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
                .activitySystemActionForegroundColor(context.dynamicColor { $0.text })
                .widgetURL(ScheduleNavigation.url)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    ScheduleLiveActivityView(context: context, inDynamicIsland: true)
                }
            } compactLeading: {
                Image(systemName: "calendar")
                    .foregroundStyle(SchedulePalette.color(context.accent(context.islandPalette)))
            } compactTrailing: {
                ScheduleActivityCountdown(context: context)
                    .font(.caption.monospacedDigit())
                    .frame(width: 54)
            } minimal: {
                Image(systemName: "calendar")
            }
            .widgetURL(ScheduleNavigation.url)
            .keylineTint(SchedulePalette.color(context.accent(context.islandPalette)))
        }
    }
}

@available(iOS 16.2, *)
private struct ScheduleLiveActivityView: View {
    let context: ActivityViewContext<ScheduleActivityAttributes>
    var inDynamicIsland = false
    @Environment(\.colorScheme) private var colorScheme
    private var palette: SchedulePalette {
        inDynamicIsland ? context.islandPalette : context.palette(systemDark: colorScheme == .dark)
    }
    private var accent: Color { SchedulePalette.color(context.accent(palette)) }
    private var secondary: Color { SchedulePalette.color(palette.secondary) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(context.attributes.title).font(.headline).lineLimit(2)
                Spacer(minLength: 8)
                Text(context.attributes.type).font(.caption).foregroundStyle(secondary)
            }
            if !context.attributes.location.isEmpty {
                Label(context.attributes.location, systemImage: "mappin.and.ellipse")
                    .font(.caption).foregroundStyle(secondary).lineLimit(1)
            }
            HStack {
                Text(context.lessonHasStarted ? "Осталось" : "До начала")
                ScheduleActivityCountdown(context: context).monospacedDigit()
                Spacer(minLength: 8)
                Text(context.attributes.end, style: .time).foregroundStyle(secondary)
            }
            .font(.subheadline)
            Group {
                if context.lessonHasStarted {
                    ProgressView(timerInterval: context.attributes.start...context.attributes.end,
                                 countsDown: false)
                } else {
                    ProgressView(value: 1)
                }
            }
            .progressViewStyle(.linear)
            .labelsHidden()
            .tint(accent)
        }
        .padding(14)
        .environment(\.timeZone, ScheduleTime.timeZone)
        .foregroundStyle(SchedulePalette.color(palette.text))
        .activityBackgroundTint(SchedulePalette.color(palette.background))
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
    var islandPalette: SchedulePalette {
        guard let appearance = state.appearance else { return .fallback(dark: true) }
        return appearance.palette(systemDark: true, forcedDark: true, override: appearance.dark)
    }

    func palette(systemDark: Bool) -> SchedulePalette {
        (state.appearance ?? .fallback).palette(systemDark: systemDark)
    }

    func accent(_ palette: SchedulePalette) -> UInt32 {
        palette.lessonAccent(typeKey: state.typeKey, fallback: attributes.accentColor)
    }

    func dynamicColor(_ getColor: @escaping (SchedulePalette) -> UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            SchedulePalette.uiColor(getColor(palette(systemDark: traits.userInterfaceStyle == .dark)))
        })
    }

    var lessonHasStarted: Bool { isStale || Date() >= attributes.start }

    var lessonInterval: ClosedRange<Date> {
        if lessonHasStarted || attributes.noticeStart >= attributes.start {
            return attributes.start...attributes.end
        }
        return attributes.noticeStart...attributes.start
    }
}
