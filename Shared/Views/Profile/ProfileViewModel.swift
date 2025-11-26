//
//  ProfileViewModel.swift
//  CoffApp
//
//  Created by Michael Critz on 11/26/25.
//

import Foundation
import Observation

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
    
    private let net: NetworkServicing
    
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

