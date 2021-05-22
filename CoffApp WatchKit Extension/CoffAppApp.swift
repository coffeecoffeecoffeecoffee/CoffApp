//
//  CoffAppApp.swift
//  CoffApp WatchKit Extension
//
//  Created by Michael Critz on 5/21/21.
//

import SwiftUI

@main
struct CoffAppApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
