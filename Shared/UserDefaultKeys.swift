import Foundation

enum UserDefaultKeys: String {
    case allGroups
    case selectedGroup
}

extension UserDefaults {
    @objc dynamic var selectedGroup: String {
        string(forKey: UserDefaultKeys.selectedGroup.rawValue) ?? "selectedGroup"
    }
}
