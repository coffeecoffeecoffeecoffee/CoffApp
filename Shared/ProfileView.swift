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
                self.statusMessage = failure.localizedDescription
                isLoggedIn = false
            }
        }
    }
}


struct LoginView: View {
    @State private var viewModel = ProfileViewModel(net: NetworkService.shared)
    
    var body: some View {
        Text(viewModel.statusMessage)
        Form {
            TextField("Email", text: $viewModel.email)
            SecureField("Password", text: $viewModel.password)
        }
        .navigationTitle("Profile")
        .onSubmit {
            viewModel.signIn()
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

@Observable
final class CreateEventViewModel {
    public var eventName: String = ""
    public var startAt: Date
    public var endAt: Date
    public var selectedVenue: Venue?
    public var venues = [Venue]()
    public var selectedGroup: InterestGroup?
    public var groups = [InterestGroups]()
    
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
                guard venue.name != nil,
                        venue.id != nil,
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
}

struct ProfileView: View {
    @State private var navPath = NavigationPath()
    @State private var profileViewModel = ProfileViewModel(net: NetworkService.shared)
    @State private var createEventViewModel = CreateEventViewModel()
    
    private func handleCreateEvent() {
        print("handleCreateEvent")
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            Form {
                TextField("Event Title", text: $createEventViewModel.eventName)
                DatePicker("Start", selection: $createEventViewModel.startAt)
                DatePicker("End", selection: $createEventViewModel.endAt)
                VenueSelectView(createEventViewModel: $createEventViewModel)
            }
            .navigationTitle("Create Event")
            .task {
                await createEventViewModel.fetchVenues()
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

struct InterestGroupSelectView: View {
    @Binding var createEventViewModel: CreateEventViewModel
    
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
        .onChange(of: createEventViewModel.selectedVenue) { old, new in
            print(new ?? "??")
        }
    }
}

struct VenueSelectView: View {
    @Binding var createEventViewModel: CreateEventViewModel
    
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
        .onChange(of: createEventViewModel.selectedVenue) { old, new in
            print(new ?? "??")
        }
    }
}

#Preview {
    ProfileView()
}
