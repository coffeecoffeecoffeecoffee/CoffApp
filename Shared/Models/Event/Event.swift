import CoffeeKit
import Foundation

public typealias Event = EventPublic

//struct Event: Codable, EventRepresentable {
//    var id: UUID?
//    var name: String
//    var groupID: UUID
//    var venue: VenuePublic
//    var imageURL: ImageURL?
//    var startAt: Date
//    var endAt: Date
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case groupID = "group_id"
//        case name
//        case imageURL = "image_url"
//        case startAt = "start_at"
//        case endAt = "end_at"
//        case venue
//    }
//}

// MARK: - Status
extension Event {
    private enum EventState: CustomStringConvertible {
        case future
        case now
        case past
        case unknown

        var description: String {
            switch self {
            case .future:
                return "Upcoming"
            case .now:
                return "Right Now"
            case .past:
                return "Previously"
            default:
                return "Unknown"
            }
        }
    }

    private var status: EventState {
        if startAt > Date.now {
            return .future
        }
        if endAt > Date.now {
            return .now
        }
        return .past
    }

    var statusText: String {
        switch status {
        case .future:
            self.status.description
        case .now:
            self.status.description
        case .past:
            ""
        case .unknown:
            ""
        }
    }
}

// MARK: - Placeholder Events
extension Event {
    /**

    static var loading: Event {
        Event(
            id: UUID(),
            groupID: UUID(),
            name: "Loading",
            imageURL: nil,
            startAt: nil,
            endAt: nil,
            venue: nil,
            venueID: nil,
        )
    }

    static var error: Event {
        Event(
            id: UUID(),
            groupID: UUID(),
            name: "Error",
            imageURL: nil,
            startAt: nil,
            endAt: nil,
            venue: nil,
            venueID: nil,
        )
    }

    static func error(text: String) -> Event {
        Event(
            id: UUID(),
            groupID: UUID(),
            name: text,
            imageURL: nil,
            startAt: nil,
            endAt: nil,
            venue: Venue(name: text, location: nil),
            venueID: nil,
        )
    }
 */
    static var empty: Event {
        let emptyVenue = VenuePublic(name: "Coffee")
        return Event(
            id: UUID(),
            name: "Coffee",
            groupID: UUID(),
            venue: emptyVenue,
            imageURL: nil,
            startAt: Date(),
            endAt: Date()
        )
    }
}


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
            let savedEvent = try? PropertyListDecoder().decode(Event.self, from: data)
        {
            return savedEvent
        }
        return nil
    }
}

// MARK: - Data formatting
extension Event {
    func localizedStartTime(_ style: DateFormatter.Style = .long) -> String {
        return DateFormatter.localizedString(
            from: startAt,
            dateStyle: style,
            timeStyle: .short
        )
    }
}
