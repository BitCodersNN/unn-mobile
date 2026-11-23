import UIKit
import Flutter
import Firebase


@main
@objc class AppDelegate: FlutterAppDelegate {
  private var scheduleActivityBridge: ScheduleActivityBridge?
  private var scheduleWidgetBridge: ScheduleWidgetBridge?
  private var paletteLinkBridge: PaletteLinkBridge?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = registrar(forPlugin: "ScheduleWidgetBridge") {
      scheduleActivityBridge = ScheduleActivityBridge(messenger: registrar.messenger())
      scheduleWidgetBridge = ScheduleWidgetBridge(
        messenger: registrar.messenger(),
        initialURL: launchOptions?[.url] as? URL
      )
      paletteLinkBridge = PaletteLinkBridge(
        messenger: registrar.messenger(),
        initialURL: launchOptions?[.url] as? URL
      )
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if scheduleWidgetBridge?.handleURL(url) == true { return true }
    if paletteLinkBridge?.handleURL(url) == true { return true }
    return super.application(app, open: url, options: options)
  }

}

private final class PaletteLinkBridge {
  private let channel: FlutterMethodChannel
  private var pendingLink: String?

  init(messenger: FlutterBinaryMessenger, initialURL: URL?) {
    channel = FlutterMethodChannel(
      name: "ru.bitcodersnn.unnstudenthub/palette_link",
      binaryMessenger: messenger
    )
    pendingLink = Self.isPaletteURL(initialURL) ? initialURL?.absoluteString : nil
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "consumeInitialLink":
      let link = pendingLink
      pendingLink = nil
      result(link)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func handleURL(_ url: URL) -> Bool {
    guard Self.isPaletteURL(url) else { return false }
    let link = url.absoluteString
    channel.invokeMethod("openPaletteLink", arguments: link) { [weak self] result in
      let failed = result is FlutterError || (result as? NSObject) == FlutterMethodNotImplemented
      self?.pendingLink = failed ? link : nil
    }
    return true
  }

  private static func isPaletteURL(_ url: URL?) -> Bool {
    url?.scheme?.lowercased() == "unnpalette"
  }
}
 
