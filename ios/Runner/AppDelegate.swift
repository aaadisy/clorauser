import UIKit
import Flutter
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register Firebase plugins
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)

    // Register for remote notifications
    DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
