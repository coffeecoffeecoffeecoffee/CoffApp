// watchOS

import SwiftUI

@main
struct CoffAppApp: App {
    @State var networkService = NetworkService()
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(networkService)
            }
        }
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
