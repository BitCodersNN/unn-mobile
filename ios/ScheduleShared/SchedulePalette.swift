// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import SwiftUI

struct SchedulePalette: Codable, Hashable {
    let background: UInt32
    let text: UInt32
    let secondary: UInt32
    let accent: UInt32
    let subjects: [String: UInt32]

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
            background: dark ? 0xFF1C1C1E : 0xFFF2F2F7,
            text: dark ? 0xFFFFFFFF : 0xFF1C1C1E,
            secondary: dark ? 0xFFC6C6C8 : 0xFF636366,
            accent: dark ? 0xFF69D9C9 : 0xFF00897F,
            subjects: [:]
        )
    }
}

struct ScheduleAppearance: Codable, Hashable {
    let mode: String
    let light: String
    let dark: String
    let palettes: [String: SchedulePalette]

    static let fallback = Self(mode: "system", light: "", dark: "", palettes: [:])

    func palette(systemDark: Bool, override: String? = nil) -> SchedulePalette {
        let useDark = override.map { $0.hasPrefix("dark_") }
            ?? (mode == "system" ? systemDark : mode == "dark")
        return palettes[override ?? (useDark ? dark : light)] ?? .fallback(dark: useDark)
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
