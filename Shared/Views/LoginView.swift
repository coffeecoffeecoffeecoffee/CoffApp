//
//  LoginView.swift
//  CoffApp
//
//  Created by Michael Critz on 11/26/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = ProfileViewModel(net: NetworkService.shared)
    
    var body: some View {
        NavigationStack {
            Form {
                #if os(iOS)
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                #else
                TextField("Email", text: $viewModel.email)
                #endif
                SecureField("Password", text: $viewModel.password)
            }
            .navigationTitle("Sign In")
            .toolbar {
                if #available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *) {
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

#Preview {
    LoginView()
}
