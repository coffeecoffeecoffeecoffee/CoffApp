//
//  CoffAppApp.swift
//  CoffApp
//
//  Created by Michael Critz on 5/21/21.
//

import SwiftUI

@main
struct CoffAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
