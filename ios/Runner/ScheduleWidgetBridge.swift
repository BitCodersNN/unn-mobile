// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Flutter
import WidgetKit

final class ScheduleWidgetBridge {
    private let channel: FlutterMethodChannel
    private var pendingLaunch: Bool

    init(messenger: FlutterBinaryMessenger, initialURL: URL?) {
        channel = FlutterMethodChannel(name: ScheduleWidgetConstants.channel,
                                       binaryMessenger: messenger)
        pendingLaunch = initialURL?.scheme == "unnhub" && initialURL?.host == "schedule-widget"
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let defaults = UserDefaults(suiteName: ScheduleWidgetConstants.appGroup) else {
            result(FlutterError(code: "APP_GROUP_UNAVAILABLE", message: "Schedule widget App Group is unavailable", details: nil))
            return
        }
        switch call.method {
        case "read":
            result(defaults.string(forKey: ScheduleWidgetConstants.dataKey))
        case "write":
            guard let value = call.arguments as? String,
                  let bytes = value.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode(ScheduleWidgetData.self, from: bytes),
                  decoded.version == 1 else {
                result(FlutterError(code: "INVALID_DATA", message: "Invalid schedule widget data", details: nil))
                return
            }
            defaults.set(value, forKey: ScheduleWidgetConstants.dataKey)
            WidgetCenter.shared.reloadTimelines(ofKind: ScheduleWidgetConstants.kind)
            result(nil)
        case "clear":
            defaults.removeObject(forKey: ScheduleWidgetConstants.dataKey)
            WidgetCenter.shared.reloadTimelines(ofKind: ScheduleWidgetConstants.kind)
            result(nil)
        case "consumeLaunch":
            let launch = pendingLaunch
            pendingLaunch = false
            result(launch)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func handleURL(_ url: URL) -> Bool {
        guard url.scheme == "unnhub", url.host == "schedule-widget" else { return false }
        channel.invokeMethod("openSchedule", arguments: nil) { [weak self] result in
            self?.pendingLaunch = result is FlutterError || (result as? NSObject) == FlutterMethodNotImplemented
        }
        return true
    }
}
