import BackgroundTasks
import SwiftUI

extension EventListView {
    func scheduleAppRefresh() {
        let meanwhile = Date.now.addingTimeInterval(15)
        let request = BGAppRefreshTaskRequest(identifier: "science.pixel.espresso.backgroundfetch")
        request.earliestBeginDate = meanwhile
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
        }
        logger.debug(.init(stringLiteral: request.debugDescription))
    }

    func removeBadgeCount() async throws {
        let resetBadgetNotification = UNMutableNotificationContent()
        resetBadgetNotification.badge = 0
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: resetBadgetNotification,
                                            trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }
}
