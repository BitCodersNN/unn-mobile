// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Foundation

final class ScheduleSnapshotProvider {
    private static let key = "schedule_widget_data"
    private let defaults: UserDefaults?

    init(defaults: UserDefaults? = UserDefaults(suiteName: ScheduleConstants.appGroup)) {
        self.defaults = defaults
    }

    var isAvailable: Bool { defaults != nil }

    func readJSON() -> String? {
        defaults?.string(forKey: Self.key)
    }

    func read() -> ScheduleSnapshot? {
        readJSON().flatMap(ScheduleSnapshot.decode)
    }

    func writeJSON(_ value: String) -> Bool {
        guard let defaults = defaults, ScheduleSnapshot.decode(value) != nil else { return false }
        defaults.set(value, forKey: Self.key)
        return true
    }

    func clear() {
        defaults?.removeObject(forKey: Self.key)
    }
}
