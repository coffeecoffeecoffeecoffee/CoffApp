//
//  EventModel.swift
//  CoffApp
//
//  Created by Michael Critz on 3/27/24.
//

import CoffeeKit
import Foundation
import SwiftData

@Model
final class EventModel {
    var id: UUID
    var groupID: UUID
    var name: String
    var imageURL: ImageURL?
    var startAt: Date
    var endAt: Date
    var venue: Venue?

    // SwiftData relationship: each event belongs to a group
    @Relationship var group: InterestGroupModel?
    
    internal init(id: UUID? = nil,
                  groupID: UUID,
                  name: String,
                  imageURL: ImageURL? = nil,
                  startAt: Date,
                  endAt: Date,
                  venue: Venue?) {
        self.id = id ?? UUID()
        self.groupID = groupID
        self.name = name
        self.imageURL = imageURL
        self.startAt = startAt
        self.endAt = endAt
        self.venue = venue
    }
    
    convenience init?(_ event: Event) {
        guard let eventID = event.id else { return nil }
        guard let groupID = event.groupID else { return nil }
        self.init(id: eventID,
                  groupID: groupID,
                  name: event.name,
                  imageURL: event.imageURL,
                  startAt: event.startAt,
                  endAt: event.endAt,
                  venue: event.venue)
    }
}

