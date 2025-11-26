import SwiftUI

@main
struct TheCoffeeAppClipApp: App {
    @State private var profile = UserProfile(net: NetworkService())
    
    var body: some Scene {
        WindowGroup {
            EventListView(profile: $profile)
        }
    }
}
