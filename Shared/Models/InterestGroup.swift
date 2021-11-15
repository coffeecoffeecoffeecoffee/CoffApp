import Combine
import Foundation

typealias InterestGroups = [InterestGroup]

struct InterestGroup: Codable {
    let id: UUID
    let name: String
}

extension InterestGroup: Equatable { }

extension InterestGroup: Identifiable { }

extension InterestGroup {
    var eventsURL: URL? {
        URL.appURL(with: "api", "groups", id.uuidString.lowercased(), "events")
    }
}
