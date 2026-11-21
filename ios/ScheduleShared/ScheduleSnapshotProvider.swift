// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Foundation

enum ScheduleSnapshotReadError {
    case storageUnavailable
    case missing
    case invalid
}

final class ScheduleSnapshotProvider {
    private static let key = "schedule_cache"
    private static let previousKey = "schedule_widget_data"
    private let defaults: UserDefaults?

    convenience init() {
        self.init(defaults: ScheduleAppGroup.resolve().flatMap { UserDefaults(suiteName: $0) })
    }

    init(defaults: UserDefaults?) {
        self.defaults = defaults
    }

    var isAvailable: Bool { defaults != nil }

    func readJSON() -> String? {
        defaults?.string(forKey: Self.key)
    }

    func read() -> ScheduleSnapshot? {
        readResult().data
    }

    func readResult() -> (data: ScheduleSnapshot?, error: ScheduleSnapshotReadError?) {
        guard isAvailable else { return (nil, .storageUnavailable) }
        guard let json = readJSON() else { return (nil, .missing) }
        guard let cache = ScheduleCacheData.decode(json) else { return (nil, .invalid) }
        guard let snapshot = cache.snapshot() else { return (nil, .missing) }
        return (snapshot, nil)
    }

    func writeJSON(_ value: String) -> Bool {
        guard let defaults = defaults, ScheduleCacheData.decode(value) != nil else { return false }
        defaults.set(value, forKey: Self.key)
        defaults.removeObject(forKey: Self.previousKey)
        return true
    }

}
