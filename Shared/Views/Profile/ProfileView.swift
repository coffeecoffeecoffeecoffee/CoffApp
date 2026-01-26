//
//  ProfileView.swift
//  CoffApp
//
//  Created by Michael Critz on 11/23/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var navPath = NavigationPath()
    @State private var profileViewModel: ProfileViewModel
    @State private var createEventViewModel: CreateEventViewModel
    @State private var showSignInForm: Bool = false
    @State private var showAlert: Bool = false
    @State private var statusMessage = "Ready"
    
    init(net: NetworkServicing) {
        self.profileViewModel = ProfileViewModel(net: net)
        self.createEventViewModel = CreateEventViewModel(net: net)
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            NavigationLink {
                LoginView(profile: $profileViewModel)
            } label: {
                Label("Profile", systemImage: "person")
            }
            
            NavigationLink {
                CreateEventView(
                    profileViewModel: $profileViewModel,
                    createEventViewModel: $createEventViewModel
                )
            } label: {
                Label("New Event", systemImage: "calendar.badge.plus")
            }
            .padding()
            
            NavigationLink {
                CreateGroupView()
            } label: {
                Label("New Group", systemImage: "person.2.badge.plus")
            }
            .padding()
        }
        .sheet(isPresented: $showSignInForm) {
            LoginView(profile: $profileViewModel)
        }
        .alert(statusMessage, isPresented: $showAlert) {
            Button {
                print("ok")
            } label: {
                Text("OK")
            }
            .buttonStyle(.borderedProminent)
        }
        .task {
            if profileViewModel.isLoggedIn == false {
                showSignInForm = true
            }
        }
    }
}

#Preview {
    @Previewable var net = PreviewNetworkService()
    ProfileView(net: net)
}
