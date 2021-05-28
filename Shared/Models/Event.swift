// swiftlint:disable identifier_name
import Foundation

struct Event: Codable {
    let id, groupID: UUID?
    let name: String
    let imageURL: URL?
    let startAt, endAt: Date?
    let venue: Venue?

    enum CodingKeys: String, CodingKey {
        case id
        case groupID = "group_id"
        case name
        case imageURL = "image_url"
        case startAt = "start_at"
        case endAt = "end_at"
        case venue
    }
}

extension Event: Hashable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        guard let lid = lhs.id,
              let rid = rhs.id else { return false }
        return lid == rid
    }
}

extension Event: Identifiable { }

// MARK: - Data formatting
extension Event {
    var venueName: String {
        guard let venueName = venue?.name else {
            return NSLocalizedString("Mystery location", comment: "")
        }
        return venueName
    }

    var localizedStartTime: String {
        guard let startAt = startAt else { return NSLocalizedString("Mystery Time", comment: "") }
        return DateFormatter.localizedString(from: startAt,
                                             dateStyle: .long,
                                             timeStyle: .short)
    }
}
