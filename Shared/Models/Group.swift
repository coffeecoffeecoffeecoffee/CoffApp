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

extension Group {
    func setSelected() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.sharedSuite.setValue(encoded, forKey: UserDefaultKeys.selectedGroup.rawValue)
        }
    }

    static func loadSelected() -> Group? {
        if let savedData = UserDefaults.sharedSuite.data(forKey: UserDefaultKeys.selectedGroup.rawValue),
           let savedGroup = try? JSONDecoder().decode(Group.self, from: savedData) {
            return savedGroup
        }
        return nil
    }
}
