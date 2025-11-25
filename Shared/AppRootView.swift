//
//  AppRootView.swift
//  CoffApp
//
//  Created by Michael Critz on 11/22/25.
//

import SwiftUI
import SwiftData
import Logging

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    private let logger = Logger(label: "science.pixel.espresso.approot")

    var body: some View {
        TabView {
            Tab {
                EventListView()
            } label: {
                Label("Events", systemImage: "cup.and.saucer.fill")
            }

            Tab {
                ProfileView()
            } label: {
                Label("Profile", systemImage: "person.fill")
            }

            Tab(role: .search) {
                GroupListView()
                    .environmentObject(UserProfile())
            } label: {
                Label("Search", systemImage: "magnifyingglass")
            }
        }
        .task {
            do {
                let groups = try await InterestGroup.fetchGroups()
                
                // Persist fetched groups using SwiftData
                try PersistenceService.update(interestGroups: groups, modelContext: modelContext)
                
                // After groups are available, fetch all events for subscribed groups
                let profile = UserProfile()
                try await profile.sync()
            } catch {
                logger.error(.init(stringLiteral: error.localizedDescription))
            }
        }
    }
}
