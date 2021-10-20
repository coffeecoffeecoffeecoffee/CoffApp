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
        BGTaskScheduler.shared.register(forTaskWithIdentifier: CoffeeBackgroundTask.refresh.rawValue,
                                        using: nil) { [weak self] bgTask in
            guard let refreshTask = bgTask as? BGAppRefreshTask else { return }
            self?.handle(backgroundTask: refreshTask)
        }
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        logger.debug("terminate")
        do {
            try scheduleBGTask()
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        logger.debug("Background app delegate")
        do {
            try scheduleBGTask()
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
        }
    }
    
    func scheduleBGTask() throws {
        logger.debug("scheduling BG task")
        let request = BGAppRefreshTaskRequest(identifier: CoffeeBackgroundTask.refresh.rawValue)
        try BGTaskScheduler.shared.submit(request)
    }

    func handle(backgroundTask: BGAppRefreshTask) {
        logger.debug("handling BG task")
        let opQ = OperationQueue()
        opQ.maxConcurrentOperationCount = 1
        opQ.addOperation {
            NetworkService().loadGroups()
            if let selectedGroup = InterestGroup.loadSelected() {
                selectedGroup.headlineEvent.saveAsMostRecent()
            }
            backgroundTask.setTaskCompleted(success: true)
        }
        opQ.qualityOfService = .background
        try? scheduleBGTask()
        backgroundTask.expirationHandler = {
            opQ.cancelAllOperations()
        }
    }
}

@main
struct CoffAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
