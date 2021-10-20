// swiftlint:disable all
import BackgroundTasks
import Logging
import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    let logger = Logger(label: "science.pixel.espresso.uiappdelegate")

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        logger.debug("didfinish launching app delegate")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: CoffeeBackgroundTask.refesh.rawValue,
                                        using: nil) { bgTask in
            guard let refreshTask = bgTask as? BGAppRefreshTask else { return }
            CoffAppApp.handle(backgroundTask: refreshTask)
        }
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        logger.debug("terminate")
        CoffAppApp.scheduleBGTask()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        logger.debug("Background app delegate")
        CoffAppApp.scheduleBGTask()
    }
}

@main
struct CoffAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared
    let logger = Logger(label: "science.pixel.espresso.coffappapp")

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    static func scheduleBGTask() {
        print("scheduled task")
        let request = BGAppRefreshTaskRequest(identifier: CoffeeBackgroundTask.refesh.rawValue)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule BG Refresh", error)
        }
    }

    static func handle(backgroundTask: BGAppRefreshTask) {
        let opQ = OperationQueue()
        opQ.maxConcurrentOperationCount = 1
        opQ.addOperation {
            NetworkService().loadGroups()
            backgroundTask.setTaskCompleted(success: true)
        }
        opQ.qualityOfService = .background
        scheduleBGTask()
        backgroundTask.expirationHandler = {
            opQ.cancelAllOperations()
        }
    }
}
