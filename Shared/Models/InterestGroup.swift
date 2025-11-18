import Foundation

typealias InterestGroups = [InterestGroup]

struct InterestGroup: Codable {
    let id: UUID
    let name: String
    let imageURL: URL?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension InterestGroup: Equatable { }

extension InterestGroup: Identifiable { }

extension InterestGroup {
    var eventsURL: URL {
        URL.appURL(with: "api", "v2", "groups", id.uuidString.lowercased(), "events")
    }
}
