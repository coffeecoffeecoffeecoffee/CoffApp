import Foundation

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
