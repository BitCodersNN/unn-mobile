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
    if let registrar = registrar(forPlugin: "ScheduleActivityBridge") {
      scheduleActivityBridge = ScheduleActivityBridge(messenger: registrar.messenger())
    }
    if let registrar = registrar(forPlugin: "ScheduleWidgetBridge") {
      scheduleWidgetBridge = ScheduleWidgetBridge(
        messenger: registrar.messenger(),
        initialURL: launchOptions?[.url] as? URL
      )
    }
    if let registrar = registrar(forPlugin: "PaletteLinkBridge") {
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
 
