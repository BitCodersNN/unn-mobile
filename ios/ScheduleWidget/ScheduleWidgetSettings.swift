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

struct ScheduleWidgetSettings {
    let textSize: ScheduleWidgetTextSize
    let maxLessons: Int
    let showLocation: Bool
    let showLecturer: Bool

    init(
        textSize: ScheduleWidgetTextSize = .normal,
        maxLessons: Int = 0,
        showLocation: Bool = true,
        showLecturer: Bool = false
    ) {
        self.textSize = textSize
        self.maxLessons = min(6, max(0, maxLessons))
        self.showLocation = showLocation
        self.showLecturer = showLecturer
    }
}
