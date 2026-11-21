// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Foundation

enum ScheduleConstants {
    static let appGroup = "group.ru.unn.unnMobile"
    static let widgetKind = "ScheduleWidget"
    static let lockScreenWidgetKind = "ScheduleLockScreenWidget"
    static let widgetChannel = "ru.bitcodersnn.unnstudenthub/schedule_widget"
}


enum ScheduleAppGroup {
    static func resolve(
        registeredGroups: [String] = Bundle.main.object(forInfoDictionaryKey: "ALTAppGroups") as? [String] ?? [],
        isAccessible: (String) -> Bool = {
            FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: $0) != nil
        }
    ) -> String? {
        let original = ScheduleConstants.appGroup
        let matching = registeredGroups.filter { $0 == original || $0.hasPrefix(original + ".") }
        let accessible = Set(matching + [original]).filter(isAccessible)
        if accessible.contains(original) { return original }
        guard accessible.count == 1 else { return nil }
        return accessible.first
    }
}
