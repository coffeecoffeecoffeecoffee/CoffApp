// swiftlint:disable identifier_name
import Foundation

struct Event: Codable {
    let id, groupID: UUID
    let name: String
    let imageURL: String
    let startAt, endAt: Date
    let venue: Venue
    let isOnline: Bool
    let onlineEventURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case groupID = "group_id"
        case name
        case imageURL = "image_url"
        case startAt = "start_at"
        case endAt = "end_at"
        case venue
        case isOnline = "is_online"
        case onlineEventURL = "online_event_url"
    }
}
