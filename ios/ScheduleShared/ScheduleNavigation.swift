// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Foundation

enum ScheduleNavigation {
    static let url = URL(string: "unnhub://schedule-widget")!

    static func isScheduleURL(_ candidate: URL?) -> Bool {
        candidate?.scheme == url.scheme && candidate?.host == url.host
    }
}
