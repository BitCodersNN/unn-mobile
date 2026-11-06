// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import SwiftUI

enum ScheduleWidgetPalette {
    static let accent = Color(red: 0, green: 0.54, blue: 0.50)

    static func background(for colorScheme: ColorScheme) -> Color {
        let traits = UITraitCollection(userInterfaceStyle: colorScheme == .dark ? .dark : .light)
        return Color(UIColor.secondarySystemBackground.resolvedColor(with: traits))
    }

    static func subjectColor(_ argb: UInt32?) -> Color {
        guard let argb = argb else { return accent }
        return Color(.sRGB, red: Double((argb >> 16) & 255) / 255,
                     green: Double((argb >> 8) & 255) / 255,
                     blue: Double(argb & 255) / 255,
                     opacity: Double((argb >> 24) & 255) / 255)
    }
}
