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

extension Event {
    static var loading: Event {
        Event(id: nil,
              groupID: nil,
              name: "Loading",
              imageURL: nil,
              startAt: nil,
              endAt: nil,
              venue: nil
        )
    }

    static var error: Event {
        Event(id: nil,
              groupID: nil,
              name: "Error",
              imageURL: nil,
              startAt: nil,
              endAt: nil,
              venue: nil
        )
    }

    static var empty: Event {
        Event(id: nil,
              groupID: nil,
              name: "No Events",
              imageURL: nil,
              startAt: nil,
              endAt: nil,
              venue: nil
        )
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

    func localizedStartTime(_ style: DateFormatter.Style = .long) -> String {
        guard let startAt = startAt else { return NSLocalizedString("Mystery Time", comment: "") }
        return DateFormatter.localizedString(from: startAt,
                                             dateStyle: style,
                                             timeStyle: .short)
    }
}
