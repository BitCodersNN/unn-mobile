// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import ActivityKit
import Foundation

@available(iOS 16.2, *)
struct ScheduleActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var updatedAt: Date
    }

    let identifier: String
    let title: String
    let type: String
    let location: String
    let start: Date
    let end: Date
    let noticeStart: Date
    let displayUntil: Date
    var accentColor: UInt32? = nil
}

struct ScheduleActivitySettings: Decodable {
    let mode: String
    let beforeMinutes: Int
    let initialMinutes: Int

    static let key = "schedule_activity_settings"

    static func read() -> ScheduleActivitySettings? {
        guard let value = UserDefaults.standard.string(forKey: key),
              let bytes = value.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Self.self, from: bytes)
    }

    var beforeInterval: TimeInterval { TimeInterval(validMinutes(beforeMinutes) * 60) }
    var initialInterval: TimeInterval { TimeInterval(validMinutes(initialMinutes) * 60) }

    private func validMinutes(_ value: Int) -> Int {
        (0...60).contains(value) ? value : 10
    }
}
