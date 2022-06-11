// swiftlint:disable identifier_name
import Combine
import Foundation

struct InterestGroup: Codable, Hashable {
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
