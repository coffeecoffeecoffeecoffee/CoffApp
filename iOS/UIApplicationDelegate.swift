import Logging
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    private let logger = Logger(label: "science.pixel.espresso.appdelegate")
    private let bgActivityController = BackgroundActivityController()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [
                        UIApplication.LaunchOptionsKey: Any
                     ]? = nil) -> Bool {
        bgActivityController.registerBackgroundTask()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        do {
            try bgActivityController.scheduleBGTask()
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        do {
            try bgActivityController.scheduleBGTask()
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
        }
    }
}
