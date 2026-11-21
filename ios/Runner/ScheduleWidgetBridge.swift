// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Flutter
import WidgetKit

@MainActor
final class ScheduleWidgetBridge {
    private let channel: FlutterMethodChannel
    private var pendingLaunch: Bool
    private let snapshotProvider = ScheduleSnapshotProvider()

    init(messenger: FlutterBinaryMessenger, initialURL: URL?) {
        channel = FlutterMethodChannel(name: ScheduleConstants.widgetChannel,
                                       binaryMessenger: messenger)
        pendingLaunch = ScheduleNavigation.isScheduleURL(initialURL)
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if ["read", "write", "clear"].contains(call.method) && !snapshotProvider.isAvailable {
            result(FlutterError(code: "APP_GROUP_UNAVAILABLE", message: "Schedule widget App Group is unavailable", details: nil))
            return
        }
        switch call.method {
        case "read":
            result(snapshotProvider.readJSON())
        case "write":
            guard let value = call.arguments as? String, snapshotProvider.writeJSON(value) else {
                result(FlutterError(code: "INVALID_DATA", message: "Invalid schedule widget data", details: nil))
                return
            }
            reloadSchedule()
            result(nil)
        case "clear":
            snapshotProvider.clear()
            reloadSchedule()
            result(nil)
        case "consumeLaunch":
            let launch = pendingLaunch
            pendingLaunch = false
            result(launch)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func reloadSchedule() {
        for kind in [ScheduleConstants.widgetKind, ScheduleConstants.lockScreenWidgetKind] {
            WidgetCenter.shared.reloadTimelines(ofKind: kind)
        }
        ScheduleActivityCoordinator.synchronize()
    }

    func handleURL(_ url: URL) -> Bool {
        guard ScheduleNavigation.isScheduleURL(url) else { return false }
        channel.invokeMethod("openSchedule", arguments: nil) { [weak self] result in
            self?.pendingLaunch = result is FlutterError || (result as? NSObject) == FlutterMethodNotImplemented
        }
        return true
    }
}
