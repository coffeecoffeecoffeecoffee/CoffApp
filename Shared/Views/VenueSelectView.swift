//
//  VenueSelectView.swift
//  CoffApp
//
//  Created by Michael Critz on 11/26/25.
//

import SwiftUI

struct VenueSelectView: View {
    @Binding var createEventViewModel: CreateEventViewModel
    @State private var venueQuery: String = ""
    
    var body: some View {
        Picker(selection: $createEventViewModel.selectedVenue) {
            ForEach(createEventViewModel.venues) { venue in
                Text(venue.name)
                    .tag(venue)
            }
        } label: {
            Text("Venue")
        }
        #if !os(macOS)
        .pickerStyle(.navigationLink)
        #endif
        .task {
            await createEventViewModel.fetchVenues()
        }
    }
}
