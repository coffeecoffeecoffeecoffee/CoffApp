// swiftlint:disable all
import BackgroundTasks
import Logging
import SwiftUI

@main
struct CoffAppApp: App {
    let persistenceController = PersistenceController.shared
    let logger = Logger(label: "science.pixel.espresso.coffapp")
    let net = NetworkService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(net)
                .onAppear(perform: {
                    // Note: SwiftUI doesn’t play nice with
                    // UIApplication.didFinishLaunching… notifications
                    logger.debug("ContentView Appears!")
                    BGTaskScheduler.shared
                        .register(forTaskWithIdentifier: CoffeeBackgroundTask.refresh.rawValue,
                                  using: nil) { bgTask in
                            guard let refreshTask = bgTask as? BGAppRefreshTask else {
                                logger.debug(.init(stringLiteral: "Not a refresh task: \(bgTask.description)"))
                                return
                            }
                            handle(backgroundTask: refreshTask)
                        }
                })
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    do {
                        try scheduleBGTask()
                    } catch {
                        logger.error(.init(stringLiteral: error.localizedDescription))
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                    do {
                        try scheduleBGTask()
                    } catch {
                        logger.error(.init(stringLiteral: error.localizedDescription))
                    }
                }
        }
    }
}

extension CoffAppApp {
    private func scheduleBGTask() throws {
        logger.debug("scheduling BG task")
        let request = BGAppRefreshTaskRequest(identifier: CoffeeBackgroundTask.refresh.rawValue)
        try BGTaskScheduler.shared.submit(request)
    }
    
    private func handle(backgroundTask: BGAppRefreshTask) {
        logger.debug("handling BG task")
        let group = DispatchGroup()
        let dispatchQ = DispatchQueue(label: "science.pixel.espresso.handlebackgroundtask",
                                      qos: .background,
                                      attributes: .concurrent,
                                      autoreleaseFrequency: .workItem)
        group.enter()
        dispatchQ.async {
            net.loadGroups()
            if let selectedGroup = InterestGroup.loadSelected() {
                selectedGroup.headlineEvent.saveAsMostRecent()
                net.loadEvents(for: selectedGroup)
            }
            backgroundTask.setTaskCompleted(success: true)
            group.leave()
        }
        group.wait()
        try? scheduleBGTask()
    }
}
