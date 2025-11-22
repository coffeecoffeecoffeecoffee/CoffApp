import Foundation
import SwiftData

@Model
final class InterestGroupModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var imageURL: URL?
    // SwiftData relationship: a group has many events
    @Relationship(deleteRule: .cascade, inverse: \EventModel.group)
    var events: [EventModel] = []

    init(id: UUID, name: String, imageURL: URL? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
}
