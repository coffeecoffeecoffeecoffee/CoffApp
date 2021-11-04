// swiftlint:disable all
import Logging
import SwiftUI

@main
struct CoffAppApp: App {
    private let persistenceController = PersistenceController.shared
    private let logger = Logger(label: "science.pixel.espresso.coffapp")
    
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
