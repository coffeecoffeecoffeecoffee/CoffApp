//
//  EventModel.swift
//  CoffApp
//
//  Created by Michael Critz on 3/27/24.
//

import Foundation
import SwiftData

@Model
final class EventModel {
    var id: UUID?
    var groupID: UUID?
    var name: String
    var imageURL: URL?
    var startAt: Date?
    var endAt: Date?
    var venue: Venue?

    // SwiftData relationship: each event belongs to a group
    @Relationship var group: InterestGroupModel?
    
    internal init(id: UUID? = nil,
                  groupID: UUID? = nil,
                  name: String,
                  imageURL: URL? = nil,
                  startAt: Date? = nil,
                  endAt: Date? = nil,
                  venue: Venue? = nil) {
        self.id = id
        self.groupID = groupID
        self.name = name
        self.imageURL = imageURL
        self.startAt = startAt
        self.endAt = endAt
        self.venue = venue
    }
    
    convenience init(_ event: Event) {
        self.init(id: event.id,
                  groupID: event.groupID,
                  name: event.name,
                  imageURL: event.imageURL,
                  startAt: event.startAt,
                  endAt: event.endAt,
                  venue: event.venue)
    }
}

