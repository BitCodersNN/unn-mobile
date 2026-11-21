// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Foundation

final class ScheduleActivityStateProvider {
    private static let key = "schedule_activity_requested"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func read() -> [String: Double] {
        defaults.dictionary(forKey: Self.key) as? [String: Double] ?? [:]
    }

    func save(_ requested: [String: Double]) {
        defaults.set(requested, forKey: Self.key)
    }

    func clear() {
        defaults.removeObject(forKey: Self.key)
    }
}
