// swiftlint:disable all
import Logging
import SwiftUI
import BackgroundTasks

@main
struct CoffAppApp: App {
    private let logger = Logger(label: "science.pixel.espresso.coffapp")
    
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
#endif
    
    var body: some Scene {
        WindowGroup {
            EventListView()
        }
        .backgroundTask(.appRefresh("science.pixel.espresso.backgroundfetch")) {
            logger.debug(.init(stringLiteral: "Fetching new events"))
            do {
                let newEvents = try await fetchNewEvents()
                await notifyForEvents(newEvents)
            } catch {
                logger.error(.init(stringLiteral: error.localizedDescription))
            }
        }
    }
}

// MARK: - Background Notifications
extension CoffAppApp {
    func fetchNewEvents() async throws -> [Event] {
        let userProfile = UserProfile()
        try await userProfile.sync()
        return userProfile.newEvents
    }
    
    func notifyForEvents(_ newEvents: [Event]) async {
        guard !newEvents.isEmpty else {
            logger.debug(.init(stringLiteral: "No new events"))
            return
        }
        let notificationContent = UNMutableNotificationContent()
        notificationContent.badge = NSNumber(integerLiteral: newEvents.count)
        
        if newEvents.count > 1 {
            notificationContent.title = "\(newEvents.count) new events"
            notificationContent.subtitle = "See what’s happening"
        } else {
            let event = newEvents.first!
            notificationContent.title = "\(event.name)"
            notificationContent.subtitle = "\(event.venueName) at \(event.localizedStartTime(.medium))"
        }
        let threeHours = 3.0 * 60.0 * 60.0 // 3 hr * 60 min * 60 sec
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: threeHours,
                                                        repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: notificationContent,
                                            trigger: trigger)
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
        }
    }
}
