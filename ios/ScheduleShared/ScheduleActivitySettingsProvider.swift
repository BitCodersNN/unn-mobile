// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Foundation

final class ScheduleActivitySettingsProvider {
    private static let key = "schedule_activity_settings"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func read() -> ScheduleActivitySettings? {
        defaults.string(forKey: Self.key).flatMap(ScheduleActivitySettings.decode)
    }

    func writeJSON(_ value: String) -> Bool {
        guard ScheduleActivitySettings.decode(value) != nil else { return false }
        defaults.set(value, forKey: Self.key)
        return true
    }
}
