// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Foundation

enum ScheduleWidgetTextSize: String, CaseIterable, Sendable {
    case small, normal, large

    var scale: CGFloat {
        switch self {
        case .small: return 0.9
        case .normal: return 1
        case .large: return 1.15
        }
    }
}

enum ScheduleWidgetPalette: String, CaseIterable, Sendable {
    case app
    case lightGreen = "light_green"
    case lightBlue = "light_blue"
    case lightWarm = "light_warm"
    case darkGreen = "dark_green"
    case darkGraphite = "dark_graphite"
    case darkWarm = "dark_warm"

    var override: String? { self == .app ? nil : rawValue }
}

struct ScheduleWidgetSettings {
    let textSize: ScheduleWidgetTextSize
    let maxLessons: Int
    let showLocation: Bool
    let showLecturer: Bool
    let palette: ScheduleWidgetPalette

    init(
        textSize: ScheduleWidgetTextSize = .normal,
        maxLessons: Int = 0,
        showLocation: Bool = true,
        showLecturer: Bool = false,
        palette: ScheduleWidgetPalette = .app
    ) {
        self.textSize = textSize
        self.maxLessons = min(6, max(0, maxLessons))
        self.showLocation = showLocation
        self.showLecturer = showLecturer
        self.palette = palette
    }
}
