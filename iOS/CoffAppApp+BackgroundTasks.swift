import BackgroundTasks
import SwiftUI

// MARK: - Background Notifications
extension CoffApp {
    func fetchNewEvents() async throws -> [Event] {
        let userProfile = UserProfile()
        try await userProfile.sync()
        return userProfile.newEvents
    }

    func notifyForEvents(_ newEvents: [Event]) async throws {
        guard !newEvents.isEmpty else {
            logger.debug(.init(stringLiteral: "No new events"))
            return
        }
        let notificationContent = UNMutableNotificationContent()
        notificationContent.badge = newEvents.count as NSNumber

        if newEvents.count > 1 {
            notificationContent.title = "\(newEvents.count) new events"
            notificationContent.subtitle = "See what’s happening"
            notificationContent.badge = newEvents.count as NSNumber
        } else {
            let event = newEvents.first!
            notificationContent.title = "\(event.name)"
            notificationContent.subtitle = "\(event.venueName) at \(event.localizedStartTime(.medium))"
            notificationContent.badge = 1
        }
        let threeHours = 3.0 * 60.0 * 60.0 // 3 hr * 60 min * 60 sec
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: threeHours,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: notificationContent,
                                            trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
        logger.debug(.init(stringLiteral: request.debugDescription))
    }

    func resetBadgeCount() async throws {
        let resetNotificationContent = UNMutableNotificationContent()
        resetNotificationContent.badge = 0
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60,
                                                        repeats: false)
        let resetRequest = UNNotificationRequest(identifier: UUID().uuidString,
                                                 content: resetNotificationContent,
                                                 trigger: trigger)
        try await UNUserNotificationCenter.current().add(resetRequest)
        logger.error(.init(stringLiteral: resetRequest.debugDescription))
    }
}
