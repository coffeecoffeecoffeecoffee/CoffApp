import CoffeeKit
import Foundation

typealias InterestGroups = [InterestGroup]

struct InterestGroup: Codable {
    let id: UUID?
    var name: String
    var imageURL: String?
    var short: String
    var isArchived: Bool?
}

extension InterestGroup: Equatable { }

extension InterestGroup: Identifiable { }

extension InterestGroup: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension InterestGroup {
    func eventsURL() throws -> URL {
        guard let groupID = id else {
            throw CoffeeErrors.invalid(reason: "Group does not have id: \(name)")
        }
        return URL.appURL(with: "api", "v2", "groups", groupID.uuidString.lowercased(), "events")
    }
}

extension InterestGroup {
    @available(*, deprecated, renamed: "NetworkServicing.fetchGroups", message: "This is not the way")
    public static func fetchGroups() async throws -> [InterestGroup] {
        let (groupsData, _) = try await URLSession.shared.data(from: .groupsURL)
        let networkGroups = try JSONDecoder().decode([InterestGroup].self,
                                                     from: groupsData)
        return networkGroups
    }
}

extension InterestGroup: InterestGroupRepresentable { }
