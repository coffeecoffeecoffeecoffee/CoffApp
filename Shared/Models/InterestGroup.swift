// swiftlint:disable identifier_name
import Combine
import Foundation

typealias InterestGroups = [InterestGroup]

struct InterestGroup: Codable {
    let id: UUID
    let name: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension InterestGroup: Equatable { }

extension InterestGroup: Identifiable { }

extension InterestGroup {
    var eventsURL: URL? {
        URL.appURL(with: "api", "groups", id.uuidString.lowercased(), "events")
    }
}
