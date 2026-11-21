// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Foundation

struct ScheduleActivitySettings: Decodable {
    let mode: String
    let beforeMinutes: Int
    let initialMinutes: Int

    static func decode(_ value: String) -> ScheduleActivitySettings? {
        guard let bytes = value.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Self.self, from: bytes)
    }

    var beforeInterval: TimeInterval { TimeInterval(validMinutes(beforeMinutes) * 60) }
    var initialInterval: TimeInterval { TimeInterval(validMinutes(initialMinutes) * 60) }

    private func validMinutes(_ value: Int) -> Int {
        (0...60).contains(value) ? value : 10
    }
}
