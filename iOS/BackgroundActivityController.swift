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
                    logger.error("Not a refresh task: \(bgTask.description)")
                    return
                }
                logger.info("Handle background task", metadata: nil)
                handle(backgroundTask: refreshTask)
            }
    }

    func scheduleBGTask() throws {
        logger.info("scheduling BG task")
        let request = BGAppRefreshTaskRequest(identifier: CoffeeBackgroundTask.refresh.rawValue)
        try BGTaskScheduler.shared.submit(request)
    }

    private func handle(backgroundTask: BGAppRefreshTask) {
        logger.info("handling BG task: BEGIN")
        guard InterestGroup.loadSelected() != nil else {
            // No saved group nothing else to do. Kill the background updates.
            backgroundTask.setTaskCompleted(success: false)
            return
        }
        do {
            try scheduleBGTask()
        } catch {
            logger.error(.init(stringLiteral: "FAIL to schedule bgtask: \(error.localizedDescription)"), metadata: nil)
        }
        logger.info("handling BG task: DONE")
        backgroundTask.setTaskCompleted(success: true)
    }
}
