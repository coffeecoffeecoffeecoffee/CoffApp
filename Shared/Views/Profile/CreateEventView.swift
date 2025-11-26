//
//  CreateEventView.swift
//  CoffApp
//
//  Created by Michael Critz on 11/26/25.
//

import SwiftUI

struct CreateEventView: View {
    @Binding var profileViewModel: ProfileViewModel
    @State private var showSignInForm: Bool = false
    @State private var showAlert: Bool = false
    @State private var statusMessage = "Ready"
    @State private var createEventViewModel = CreateEventViewModel()
    
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
            if #available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *) {
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

#Preview {
    @Previewable
    @State var previewProfileViewModel = ProfileViewModel(net: .shared)
    CreateEventView(profileViewModel: $previewProfileViewModel)
}
