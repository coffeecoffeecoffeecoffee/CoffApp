//
//  ProfileView.swift
//  CoffApp
//
//  Created by Michael Critz on 11/23/25.
//

import SwiftUI

@Observable
final class ProfileViewModel {
    public var email = ""
    public var password = ""
    public var showAlert = false
    public var statusMessage = "Sign In"
    public var isLoggedIn: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isLoggedIn")
        }
        get {
            UserDefaults.standard.bool(forKey: "isLoggedIn")
        }
    }
    
    private let net: NetworkService
    
    init(net: NetworkService) {
        self.net = net
    }
    
    public func signIn() {
        guard email.isEmpty == false, password.isEmpty == false else {
            statusMessage = "Please enter an email and password."
            showAlert = true
            return
        }
        Task {
            let result = await net.signIn(email, password: password)
            switch result {
            case .success(let success):
                self.statusMessage = success
                isLoggedIn = true
            case .failure(let failure):
                switch failure {
                case .invalid(let reason):
                    fallthrough
                case .syncError(let reason):
                    statusMessage = reason
                case .signInRequired:
                    break
                }
                isLoggedIn = false
                showAlert = true
            }
        }
    }
}


struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = ProfileViewModel(net: NetworkService.shared)
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                SecureField("Password", text: $viewModel.password)
            }
            .navigationTitle("Sign In")
            .toolbar {
                if #available(iOS 26.0, *) {
                    Button(role: .confirm) {
                        viewModel.signIn()
                    }
                } else {
                    Button {
                        viewModel.signIn()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .onSubmit {
                viewModel.signIn()
            }
            .onChange(of: viewModel.isLoggedIn) { _, new in
                if new {
                    dismiss()
                }
            }
            .alert("Oops", isPresented: $viewModel.showAlert) {
                Button("OK") {
                    viewModel.showAlert = false
                }
                .buttonStyle(.borderedProminent)
            } message: {
                Text(viewModel.statusMessage)
            }
        }
    }
}

@Observable
final class CreateEventViewModel {
    public var eventName: String = ""
    public var startAt: Date
    public var endAt: Date
    public var selectedVenue: Venue?
    public var venues = [Venue]()
    public var selectedGroup: InterestGroup?
    public var groups = [InterestGroup]()
    
    private let net = NetworkService.shared
    
    init() {
        startAt = .now.adding(2, component: .day)?.rounded(to: .hour)
            ?? .now.advanced(by: 120).rounded()
        endAt = .now
            .adding(2, component: .day)?
            .adding(2, component: .hour)?
            .rounded()
            ?? .now
            .advanced(by: 240)
            .rounded()
    }
    
    public func fetchVenues() async {
        do {
            venues = try await net.loadVenues().compactMap { venue in
                guard venue.id != nil,
                      venue.location != nil
                else {
                    return nil
                }
                return venue
            }
        } catch {
            // TODO: handle failure
            print(error.localizedDescription)
        }
    }
    
    public func fetchGroups() async {
        do {
            groups = try await net.loadGroups()
        } catch {
            // TODO: handle failure here, too
            print(error.localizedDescription)
        }
    }
    
    @discardableResult
    public func createEvent() async -> Result<Event, CoffeeErrors> {
        guard eventName.isEmpty == false,
              let selectedVenue,
              let selectedGroup
        else {
            return .failure(CoffeeErrors.invalid(reason: "Missing required fields"))
        }
        let event = Event(id: UUID(),
                          name: eventName,
                          groupID: selectedGroup.id,
                          venue: selectedVenue,
                          imageURL: nil,
                          startAt: startAt,
                          endAt: endAt)
        let result = await net.createEvent(event)
        return result
    }
}

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

struct VenueSelectView: View {
    @Binding var createEventViewModel: CreateEventViewModel
    @State private var venueQuery: String = ""
    
    var body: some View {
        Picker(selection: $createEventViewModel.selectedVenue) {
            ForEach(createEventViewModel.venues) { venue in
                Text(venue.name ?? "Unknown Venue")
                    .tag(venue)
            }
        } label: {
            Text("Venue")
        }
        .pickerStyle(.navigationLink)
        .task {
            await createEventViewModel.fetchVenues()
        }
    }
}

struct InterestGroupSelectView: View {
    @Binding var createEventViewModel: CreateEventViewModel
    
    var body: some View {
        Picker(selection: $createEventViewModel.selectedGroup) {
            ForEach(createEventViewModel.groups) { group in
                Text(group.name)
                    .tag(group)
            }
        } label: {
            Text("Group")
        }
        .pickerStyle(.navigationLink)
        .task {
            await createEventViewModel.fetchGroups()
        }
    }
}

#Preview {
    ProfileView()
}
