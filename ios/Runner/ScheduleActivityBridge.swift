// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import ActivityKit
import Flutter
import UIKit

@MainActor
final class ScheduleActivityBridge {
    private let channel: FlutterMethodChannel
    private let settingsProvider = ScheduleActivitySettingsProvider()

    init(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: ScheduleConstants.activityChannel,
                                       binaryMessenger: messenger)
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "configure":
            guard ScheduleSnapshotProvider().isAvailable else {
                result(FlutterError(code: "APP_GROUP_UNAVAILABLE", message: "Schedule App Group is unavailable", details: nil))
                return
            }
            guard let value = call.arguments as? String, settingsProvider.writeJSON(value) else {
                result(FlutterError(code: "INVALID_SETTINGS", message: "Invalid activity settings", details: nil))
                return
            }
            ScheduleActivityCoordinator.synchronize()
            result(nil)
        case "status":
            if #available(iOS 16.2, *) {
                result(["supported": true, "authorized": ActivityAuthorizationInfo().areActivitiesEnabled])
            } else {
                result(["supported": false, "authorized": false])
            }
        case "requestPermission":
            if #available(iOS 16.2, *) {
                result(ActivityAuthorizationInfo().areActivitiesEnabled)
            } else { result(false) }
        case "systemSettings", "exactAlarmSettings":
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

@MainActor
enum ScheduleActivityCoordinator {
    private static var pending: Task<Void, Never>?
    private static var timer: Timer?
    private static let settingsProvider = ScheduleActivitySettingsProvider()
    private static let snapshotProvider = ScheduleSnapshotProvider()
    private static let stateProvider = ScheduleActivityStateProvider()

    static func synchronize() {
        guard #available(iOS 16.2, *) else { return }
        let previous = pending
        pending = Task {
            await previous?.value
            await reconcile()
        }
    }

    @available(iOS 16.2, *)
    private static func reconcile() async {
        timer?.invalidate()
        let now = Date()
        let settings = settingsProvider.read()
        let data = snapshotProvider.read()
        let enabled = settings?.mode == "full" || settings?.mode == "brief"
        guard enabled, let settings = settings, let data = data,
              data.validFrom <= now.timeIntervalSince1970 * 1000,
              data.validUntil > now.timeIntervalSince1970 * 1000,
              ActivityAuthorizationInfo().areActivitiesEnabled else {
            await endAll()
            stateProvider.clear()
            return
        }
        var requested = stateProvider.read()
        requested = requested.filter { $0.value > now.timeIntervalSince1970 }
        let candidates = data.lessons.compactMap { lesson -> (attributes: ScheduleActivityAttributes, typeKey: String?)? in
            let end = settings.mode == "brief"
                ? min(lesson.endDate, lesson.startDate.addingTimeInterval(settings.initialInterval))
                : lesson.endDate
            let notice = lesson.startDate.addingTimeInterval(-settings.beforeInterval)
            guard lesson.endDate > lesson.startDate, end > now, end > notice else { return nil }
            if #available(iOS 26.0, *) {} else if notice > now { return nil }
            let attributes = ScheduleActivityAttributes(
                identifier: "\(lesson.id)|\(settings.mode)|\(settings.beforeMinutes)|\(settings.initialMinutes)|\(lesson.accentColor ?? 0)",
                title: lesson.title, type: lesson.type, location: lesson.location,
                start: lesson.startDate, end: lesson.endDate, noticeStart: notice, displayUntil: end,
                accentColor: lesson.accentColor)
            return (attributes, lesson.typeKey)
        }.sorted { $0.attributes.start < $1.attributes.start }
        let appearance = ScheduleAppearanceStore().read()
        let desired = candidates.map(\.attributes)
        let typeKeysByIdentifier = Dictionary(
            candidates.map { ($0.attributes.identifier, $0.typeKey) }, uniquingKeysWith: { first, _ in first })
        let identifiers = Set(desired.map(\.identifier))
        let existing = Activity<ScheduleActivityAttributes>.activities
        for activity in existing where !identifiers.contains(activity.attributes.identifier)
                || activity.attributes.displayUntil <= now {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        for activity in existing where identifiers.contains(activity.attributes.identifier)
                && activity.attributes.displayUntil > now {
            let attributes = activity.attributes
            let state = activity.content.state
            let typeKey = typeKeysByIdentifier[attributes.identifier] ?? nil
            let started = now >= attributes.start
            guard state.appearance != appearance || state.typeKey != typeKey
                    || (started && state.updatedAt < attributes.start) else { continue }
            await activity.update(ActivityContent(
                state: ScheduleActivityAttributes.ContentState(updatedAt: now, appearance: appearance, typeKey: typeKey),
                staleDate: started ? attributes.displayUntil : attributes.start))
        }
        let running = Set(existing.filter { $0.activityState != .ended && $0.activityState != .dismissed }
            .map { $0.attributes.identifier })
        if UIApplication.shared.applicationState == .active {
            for attributes in desired where !running.contains(attributes.identifier) && requested[attributes.identifier] == nil {
                do {
                    let state = ScheduleActivityAttributes.ContentState(
                        updatedAt: now, appearance: appearance,
                        typeKey: typeKeysByIdentifier[attributes.identifier] ?? nil)
                    try request(attributes, state: state, now: now)
                } catch {
                    let failure = error as NSError
                    NSLog("Schedule activity request failed (%@, %ld)", failure.domain, failure.code)
                    break
                }
                requested[attributes.identifier] = attributes.displayUntil.timeIntervalSince1970
            }
        }
        stateProvider.save(requested)
        let boundaries = desired.flatMap { [$0.noticeStart, $0.start, $0.displayUntil] }
            + [Date(timeIntervalSince1970: data.validUntil / 1000)]
        if let next = boundaries.filter({ $0 > now }).min() {
            timer = Timer.scheduledTimer(withTimeInterval: max(0.1, next.timeIntervalSinceNow), repeats: false) { _ in
                Task { @MainActor in synchronize() }
            }
        }
    }

    @available(iOS 16.2, *)
    private static func request(
        _ attributes: ScheduleActivityAttributes, state: ScheduleActivityAttributes.ContentState, now: Date
    ) throws {
        let content = ActivityContent(
            state: state,
            staleDate: attributes.start > now ? attributes.start : attributes.displayUntil)
        if #available(iOS 26.0, *), attributes.noticeStart > now {
            _ = try Activity.request(attributes: attributes, content: content, style: .standard,
                alertConfiguration: AlertConfiguration(title: "Скоро занятие", body: "Откройте расписание", sound: .default),
                start: attributes.noticeStart)
        } else {
            _ = try Activity.request(attributes: attributes, content: content, pushType: nil)
        }
    }

    @available(iOS 16.2, *)
    private static func endAll() async {
        for activity in Activity<ScheduleActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
