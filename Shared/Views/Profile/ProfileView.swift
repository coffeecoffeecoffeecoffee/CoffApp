//
//  ProfileView.swift
//  CoffApp
//
//  Created by Michael Critz on 11/23/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var navPath = NavigationPath()
    @State private var profileViewModel = ProfileViewModel(net: NetworkService.shared)
    @State private var createEventViewModel = CreateEventViewModel()
    @State private var statusMessage = "Ready"
    @State private var showAlert = false
    @State private var showSignInForm = false
    
    private func handleCreateEvent() {
        Task {
            let result = await createEventViewModel.createEvent()
            switch result {
            case .success(let event):
                statusMessage = "Created: \(event.name)"
            case .failure(let failure):
                switch failure {
                case .signInRequired:
                    showSignInForm = true
                case .syncError(reason: let reason):
                    statusMessage = reason
                    showAlert = true
                case .invalid(reason: let invalidReason):
                    statusMessage = invalidReason
                    showAlert = true
                @unknown default:
                    statusMessage = "Error: \(String(describing: failure))"
                    showAlert = true
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            Form {
                TextField("Event Title", text: $createEventViewModel.eventName)
                DatePicker("Start", selection: $createEventViewModel.startAt)
                DatePicker("End", selection: $createEventViewModel.endAt)
                VenueSelectView(createEventViewModel: $createEventViewModel)
                InterestGroupSelectView(createEventViewModel: $createEventViewModel)
            }
            .sheet(isPresented: $showSignInForm) {
                LoginView()
            }
            .alert(statusMessage, isPresented: $showAlert) {
                Button {
                    print("ok")
                } label: {
                    Text("OK")
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Create Event")
            .task {
                await createEventViewModel.fetchVenues()
                await createEventViewModel.fetchGroups()
                if profileViewModel.isLoggedIn == false {
                    showSignInForm = true
                }
            }
            .toolbar {
                if #available(iOS 26.0, *) {
                    Button(role: .confirm) {
                        handleCreateEvent()
                    }
                } else {
                    Button("Create Event") {
                        handleCreateEvent()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
