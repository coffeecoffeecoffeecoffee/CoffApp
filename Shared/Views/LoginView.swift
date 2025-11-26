//
//  LoginView.swift
//  CoffApp
//
//  Created by Michael Critz on 11/26/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var profile: ProfileViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                #if os(iOS)
                TextField("Email", text: $profile.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                #else
                TextField("Email", text: $profile.email)
                #endif
                SecureField("Password", text: $profile.password)
            }
            .navigationTitle("Sign In")
            .toolbar {
                if #available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *) {
                    Button(role: .confirm) {
                        profile.signIn()
                    }
                } else {
                    Button {
                        profile.signIn()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .onSubmit {
                profile.signIn()
            }
            .onChange(of: profile.isLoggedIn) { _, new in
                if new {
                    dismiss()
                }
            }
            .alert("Oops", isPresented: $profile.showAlert) {
                Button("OK") {
                    profile.showAlert = false
                }
                .buttonStyle(.borderedProminent)
            } message: {
                Text(profile.statusMessage)
            }
        }
    }
}

#Preview {
    @Previewable
    @State var profile = ProfileViewModel(net: PreviewNetworkService())
    LoginView(profile: $profile)
}
