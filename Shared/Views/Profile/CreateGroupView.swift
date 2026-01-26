//
//  CreateGroupView.swift
//  CoffApp
//
//  Created by Michael Critz on 11/30/25.
//

import SwiftUI

@Observable
final class CreateGroupViewModel {
    var status: CoffeeStatus = .pristine
    var groupName: String = ""
    var id: UUID = UUID()
    
    @discardableResult
    public func createGroup() -> Result<InterestGroup, CoffeeErrors> {
        return .failure(.invalid(reason: "NOT IMPLEMENTED"))
    }
}

struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = CreateGroupViewModel()
    
    private func handleCreate() {
        Task {
            
        }
    }
    
    var body: some View {
        Form {
            TextField("Name", text: $viewModel.groupName)
        }
        .toolbar {
            if #available(iOS 26.0, watchOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, *) {
                Button(role: .confirm) {
                    Task {
                        viewModel.createGroup()
                    }
                }
            } else {
                Button {
                    Task {
                        viewModel.createGroup()
                    }
                } label: {
                    Text("Create")
                }
            }
        }
        .navigationTitle("Create Group")
    }
}


#Preview {
    NavigationStack {
        CreateGroupView()
    }
}
