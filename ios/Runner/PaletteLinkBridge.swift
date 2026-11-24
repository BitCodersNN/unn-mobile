// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import Flutter

@MainActor
final class PaletteLinkBridge {
    private let channel: FlutterMethodChannel
    private var pendingLink: String?
    private var launchLink: String?
    private var launchDeadline: Date?

    init(messenger: FlutterBinaryMessenger, initialURL: URL?) {
        channel = FlutterMethodChannel(
            name: ScheduleConstants.paletteLinkChannel,
            binaryMessenger: messenger
        )
        let initialLink = Self.isPaletteURL(initialURL) ? initialURL?.absoluteString : nil
        pendingLink = initialLink
        launchLink = initialLink
        launchDeadline = initialLink == nil ? nil : Date().addingTimeInterval(2)
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "consumeInitialLink":
            let link = pendingLink
            pendingLink = nil
            if let launchDeadline, Date() >= launchDeadline {
                launchLink = nil
                self.launchDeadline = nil
            }
            result(link)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func handleURL(_ url: URL) -> Bool {
        guard Self.isPaletteURL(url) else { return false }
        let link = url.absoluteString
        let isLaunchEcho = link == launchLink && launchDeadline.map { Date() < $0 } == true
        if link == pendingLink || isLaunchEcho {
            launchLink = nil
            launchDeadline = nil
            return true
        }
        launchLink = nil
        launchDeadline = nil
        channel.invokeMethod("openPaletteLink", arguments: link) { [weak self] result in
            let failed = result is FlutterError || (result as? NSObject) == FlutterMethodNotImplemented
            if failed {
                self?.pendingLink = link
            } else if self?.pendingLink == link {
                self?.pendingLink = nil
            }
        }
        return true
    }

    private static let maxLinkLength = 8192
    private static let deepLinkScheme = "unnpalette"
    private static let deepLinkHost = "import"

    private static func isPaletteURL(_ url: URL?) -> Bool {
        guard let url, url.absoluteString.count <= maxLinkLength else { return false }
        return url.scheme?.lowercased() == deepLinkScheme &&
            url.host?.lowercased() == deepLinkHost
    }
}
