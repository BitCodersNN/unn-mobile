// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import AppIntents
import WidgetKit

@available(iOS 17.0, *)
extension ScheduleWidgetTextSize: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Размер текста" }
    static var caseDisplayRepresentations: [ScheduleWidgetTextSize: DisplayRepresentation] {
        [.small: "Компактный", .normal: "Обычный", .large: "Крупный"]
    }
}

@available(iOS 17.0, *)
enum ScheduleWidgetLessonLimit: String, AppEnum {
    case automatic, one, two, three, four, five, six

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Количество занятий" }
    static var caseDisplayRepresentations: [ScheduleWidgetLessonLimit: DisplayRepresentation] {
        [
            .automatic: "По размеру виджета",
            .one: "Не больше 1",
            .two: "Не больше 2",
            .three: "Не больше 3",
            .four: "Не больше 4",
            .five: "Не больше 5",
            .six: "Не больше 6"
        ]
    }

    var count: Int {
        switch self {
        case .automatic: return 0
        case .one: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        }
    }
}

@available(iOS 17.0, *)
struct ScheduleWidgetConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Настройки расписания" }
    static var description: IntentDescription {
        "Выберите размер текста, количество занятий и информацию о них. Если места мало, занятий будет меньше."
    }

    @Parameter(title: "Размер текста", default: .normal)
    var textSize: ScheduleWidgetTextSize

    @Parameter(title: "Количество занятий", default: .automatic)
    var lessonLimit: ScheduleWidgetLessonLimit

    @Parameter(title: "Показывать аудиторию", default: true)
    var showLocation: Bool

    @Parameter(title: "Показывать преподавателя", default: false)
    var showLecturer: Bool

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$textSize
            \.$lessonLimit
            \.$showLocation
            \.$showLecturer
        }
    }

    var settings: ScheduleWidgetSettings {
        ScheduleWidgetSettings(
            textSize: textSize,
            maxLessons: lessonLimit.count,
            showLocation: showLocation,
            showLecturer: showLecturer
        )
    }
}

@available(iOS 17.0, *)
struct ConfigurableScheduleProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleWidgetTimeline.placeholder()
    }

    func snapshot(for configuration: ScheduleWidgetConfiguration, in context: Context) async -> ScheduleEntry {
        ScheduleWidgetTimeline.snapshot(isPreview: context.isPreview, settings: configuration.settings)
    }

    func timeline(for configuration: ScheduleWidgetConfiguration, in context: Context) async -> Timeline<ScheduleEntry> {
        ScheduleWidgetTimeline.timeline(settings: configuration.settings)
    }
}
