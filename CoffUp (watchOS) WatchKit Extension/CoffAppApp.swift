// watchOS

import SwiftUI
import SwiftData

@main
struct CoffAppApp: App {
    private var networkService = NetworkService()
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(networkService)
            }
        }
        .modelContainer(for: [InterestGroupModel.self, EventModel.self])
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

