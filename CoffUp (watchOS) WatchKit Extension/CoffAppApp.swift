//
//  CoffAppApp.swift
//  CoffUp (watchOS) WatchKit Extension
//
//  Created by Michael Critz on 5/28/21.
//

import SwiftUI

@main
struct CoffAppApp: App {
    let networkService = NetworkService()
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
