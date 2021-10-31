// swiftlint:disable all
import Logging
import SwiftUI

@main
struct CoffAppApp: App {
    private let persistenceController = PersistenceController.shared
    private let logger = Logger(label: "science.pixel.espresso.coffapp")
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
