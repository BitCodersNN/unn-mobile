// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Foundation

struct ScheduleLesson: Decodable, Identifiable {
    let title: String
    let type: String
    let location: String
    let lecturer: String
    let start: Double
    let end: Double
    var accentColor: UInt32? = nil

    var id: String { "\(start)|\(end)|\(title)|\(location)" }
    var startDate: Date { Date(timeIntervalSince1970: start / 1000) }
    var endDate: Date { Date(timeIntervalSince1970: end / 1000) }
}

