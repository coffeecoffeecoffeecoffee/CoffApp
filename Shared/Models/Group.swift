// swiftlint:disable identifier_name
import Combine
import Foundation

struct Group: Codable {
    let id: UUID
    let name: String
}

extension Group: Equatable { }

extension Group: Identifiable { }

extension Group {
    var eventsURL: URL? {
        URL(string: "https://coffeecoffeecoffee.coffee/api/groups/\(id.uuidString.lowercased())/events")
    }
}
