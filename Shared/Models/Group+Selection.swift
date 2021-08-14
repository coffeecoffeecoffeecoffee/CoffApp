import Foundation

extension InterestGroup {
    func setSelected() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.sharedSuite.setValue(encoded, forKey: UserDefaultKeys.selectedGroup.rawValue)
        }
    }

    static func loadSelected() -> InterestGroup? {
        if let savedData = UserDefaults.sharedSuite.data(forKey: UserDefaultKeys.selectedGroup.rawValue),
           let savedGroup = try? JSONDecoder().decode(InterestGroup.self, from: savedData) {
            return savedGroup
        }
        return nil
    }
}
