// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import SwiftUI

struct SchedulePalette: Codable, Hashable {
    let background: UInt32
    let text: UInt32
    let secondary: UInt32
    let accent: UInt32
    let subjects: [String: UInt32]
    let dark: Bool?

    func lessonAccent(typeKey: String?, fallback: UInt32?) -> UInt32 {
        typeKey.flatMap { subjects[$0] } ?? fallback ?? accent
    }

    static func color(_ argb: UInt32) -> Color { Color(uiColor: uiColor(argb)) }

    static func uiColor(_ argb: UInt32) -> UIColor {
        UIColor(red: CGFloat((argb >> 16) & 255) / 255,
                green: CGFloat((argb >> 8) & 255) / 255,
                blue: CGFloat(argb & 255) / 255,
                alpha: CGFloat((argb >> 24) & 255) / 255)
    }

    static func fallback(dark: Bool) -> Self {
        Self(
            background: dark ? 0xFF192522 : 0xFFF4FBFA,
            text: dark ? 0xFFE0F1EC : 0xFF172B28,
            secondary: dark ? 0xFFA2BBB3 : 0xFF637B77,
            accent: dark ? 0xFF69D9C9 : 0xFF00897F,
            subjects: [:],
            dark: dark
        )
    }
}

struct SchedulePaletteOption: Codable, Hashable, Sendable {
    let key: String
    let label: String
    let dark: Bool
}

struct ScheduleAppearance: Codable, Hashable {
    let mode: String
    let light: String
    let dark: String
    let palettes: [String: SchedulePalette]
    let options: [SchedulePaletteOption]?

    static let fallback = Self(mode: "system", light: "", dark: "", palettes: [:], options: nil)

    func palette(systemDark: Bool, forcedDark: Bool? = nil, override: String? = nil) -> SchedulePalette {
        let overrideKey = override.flatMap { $0.isEmpty ? nil : $0 }
        let overridePalette = overrideKey.flatMap { palettes[$0] }
        let useDark: Bool
        if let overrideKey {
            useDark = overridePalette?.dark ?? overrideKey.hasPrefix("dark_")
        } else {
            useDark = forcedDark ?? (mode == "system" ? systemDark : mode == "dark")
        }
        let activeKey = useDark ? dark : light
        return overridePalette ?? palettes[activeKey] ?? .fallback(dark: useDark)
    }
}

struct ScheduleAppearanceStore {
    private static let key = "schedule_appearance"
    private let defaults = ScheduleAppGroup.resolve().flatMap { UserDefaults(suiteName: $0) }

    func read() -> ScheduleAppearance? {
        defaults?.data(forKey: Self.key).flatMap { try? JSONDecoder().decode(ScheduleAppearance.self, from: $0) }
    }

    func save(_ json: String) -> Bool? {
        guard let defaults, let data = json.data(using: .utf8),
              (try? JSONDecoder().decode(ScheduleAppearance.self, from: data)) != nil else {
            return nil
        }
        guard defaults.data(forKey: Self.key) != data else { return false }
        defaults.set(data, forKey: Self.key)
        return true
    }
}
