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
    private let net: NetworkService
    @State private var profile: UserProfile
    
    init() {
        let net = NetworkService()
        self.net = net
        self.profile = UserProfile(net: net)
    }

    var body: some View {
        TabView {
            Tab {
                EventListView(profile: $profile)
            } label: {
                Label("Events", systemImage: "cup.and.saucer.fill")
            }

            Tab {
                ProfileView(net: net)
            } label: {
                Label("Profile", systemImage: "person.fill")
            }

            Tab(role: .search) {
                GroupListView(net: net)
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
                try await profile.sync()
            } catch {
                logger.error(.init(stringLiteral: error.localizedDescription))
            }
        }
    }
}
