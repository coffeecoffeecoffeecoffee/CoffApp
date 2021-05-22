// swiftlint:disable identifier_name
import Foundation

struct Group: Codable {
    let id: UUID
    let name: String
}

extension Group {
    var eventsURL: URL? {
        URL(string: "https://coffeecoffeecoffee.coffee/api/groups/\(id.uuidString)/events")
    }
}
