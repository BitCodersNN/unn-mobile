// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import ActivityKit
import Foundation

@available(iOS 16.2, *)
struct ScheduleActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var updatedAt: Date
        var appearance: ScheduleAppearance? = nil
        var typeKey: String? = nil
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
