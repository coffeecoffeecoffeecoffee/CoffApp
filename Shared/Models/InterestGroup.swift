// swiftlint:disable identifier_name
import Combine
import Foundation

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
