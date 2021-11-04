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

// MARK: - Event States
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

    static func error(text: String) -> Event {
        Event(id: nil,
              groupID: nil,
              name: text,
              imageURL: nil,
              startAt: nil,
              endAt: nil,
              venue: Venue(name: text, location: nil))
    }

    static var empty: Event {
        Event(id: nil,
              groupID: nil,
              name: "Coffee: The True Dark Lord",
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

// MARK: - Pesistence
extension Event {
    func saveAsMostRecent() {
        if let data = try? PropertyListEncoder().encode(self) {
            UserDefaults.sharedSuite
                .setValue(data, forKey: UserDefaultKeys.mostRecentEvent.rawValue)
        }
    }

    static func loadMostRecent() -> Event? {
        if let data = UserDefaults.sharedSuite
            .data(forKey: UserDefaultKeys.mostRecentEvent.rawValue),
           let savedEvent = try? PropertyListDecoder().decode(Event.self, from: data) {
            return savedEvent
        }
        return nil
    }
}

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
