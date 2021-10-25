// swiftlint:disable identifier_name
import BackgroundTasks
import Logging

struct BackgroundActivityController {
    let net = NetworkService()
    let logger = Logger(label: "science.pixel.espresso.backgroundactivitycontroller")

    func registerBackgroundTask(_ id: String = CoffeeBackgroundTask.refresh.rawValue) {
        BGTaskScheduler.shared
            .register(forTaskWithIdentifier: id,
                      using: nil) { bgTask in
                guard let refreshTask = bgTask as? BGAppRefreshTask else {
                    logger.error(.init(stringLiteral: "Not a refresh task: \(bgTask.description)"))
                    return
                }
                handle(backgroundTask: refreshTask)
            }
    }

    func scheduleBGTask() throws {
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
