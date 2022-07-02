// swiftlint:disable all
import Logging
import SwiftUI
import BackgroundTasks

@main
struct CoffAppApp: App {
    internal let logger = Logger(label: "science.pixel.espresso.coffapp")
    
    var body: some Scene {
        WindowGroup {
            EventListView()
        }
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
#endif
    }
}
