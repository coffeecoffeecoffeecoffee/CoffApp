import Logging
import SwiftData
import SwiftUI
import BackgroundTasks

@main
struct CoffApp: App {
    internal let logger = Logger(label: "science.pixel.espresso.coffapp")
    private let net: NetworkService
    let userProfile: UserProfile

    init() {
        let net = NetworkService()
        self.net = net
        self.userProfile = UserProfile(net: net)
        URLCache.shared.memoryCapacity =  50_000_000
        URLCache.shared.diskCapacity =   500_000_000
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [InterestGroupModel.self, EventModel.self])
#if os(iOS)
        .backgroundTask(.appRefresh("science.pixel.espresso.backgroundfetch")) {
            logger.debug(.init(stringLiteral: "Fetching new events"))
            do {
                let newEvents = try await fetchNewEvents()
                try await notifyForEvents(newEvents)
            } catch {
                logger.error(.init(stringLiteral: error.localizedDescription))
            }
        }
#elseif !os(watchOS) && !os(tvOS)
        .commands {
            CommandMenu("Coffee") {
                Button("Refresh") {
                    let refreshNotification = Notification(name: .init("science.pixel.espresso.refresh-view"))
                    NotificationCenter.default.post(refreshNotification)
                }
                .keyboardShortcut(KeyEquivalent("r"), modifiers: .command)
            }
        }
#endif
    }
}
