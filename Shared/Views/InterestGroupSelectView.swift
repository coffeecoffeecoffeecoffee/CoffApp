//
//  InterestGroupSelectView.swift
//  CoffApp
//
//  Created by Michael Critz on 11/26/25.
//

import SwiftUI

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
