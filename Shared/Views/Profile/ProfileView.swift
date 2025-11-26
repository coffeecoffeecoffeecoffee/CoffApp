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
    
    var body: some View {
        NavigationStack(path: $navPath) {
            NavigationLink("Create Event") {
                CreateEventView(profileViewModel: $profileViewModel)
            }
        }
    }
}

#Preview {
    ProfileView()
}
