import SwiftUI

@main
struct CoffAppApp: App {
    let persistenceController = PersistenceController.shared
    let networkService = NetworkService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(networkService)
                .accessibility(identifier: "Identifier"/*@END_MENU_TOKEN@*/)
        }
    }
}
