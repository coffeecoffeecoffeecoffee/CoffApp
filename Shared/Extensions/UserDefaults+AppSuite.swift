import Foundation

extension UserDefaults {
    static let appSuiteID = "group.science.pixel.espresso"

    static let sharedSuite: UserDefaults = {
        UserDefaults.init(suiteName: appSuiteID) ?? .standard
    }()

    @objc dynamic var selectedGroup: String {
        string(forKey: UserDefaultKeys.selectedGroup.rawValue) ?? ""
    }
}
