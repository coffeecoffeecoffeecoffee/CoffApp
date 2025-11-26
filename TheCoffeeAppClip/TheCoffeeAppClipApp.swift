import SwiftUI

@main
struct TheCoffeeAppClipApp: App {
    private let net = NetworkService()
    var body: some Scene {
        WindowGroup {
            EventListView(net: net)
        }
    }
}
