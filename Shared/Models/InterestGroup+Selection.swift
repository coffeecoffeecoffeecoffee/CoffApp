import Foundation

// MARK: Selection
extension InterestGroup {
    func setSelected() {
        if let encoded = try? PropertyListEncoder().encode(self) {
            UserDefaults.sharedSuite.setValue(encoded, forKey: UserDefaultKeys.selectedGroup.rawValue)
        }
    }

    static func loadSelected() -> InterestGroup? {
        if let savedData = UserDefaults.sharedSuite.data(forKey: UserDefaultKeys.selectedGroup.rawValue),
           let savedGroup = try? PropertyListDecoder().decode(InterestGroup.self, from: savedData) {
            return savedGroup
        }
        return nil
    }
}

// MARK: - Events
extension InterestGroup {
    func headlineEvent() async throws -> Event {
        let net = NetworkService()
        guard let events = try? await net.futureEvents(for: self),
              !events.isEmpty else {
                  return Event.loadMostRecent() ?? Event.error(text: "Coffee: YES!")
        }
        let sortedEvets = events.sorted(by: {
            guard let aStart = $0.startAt,
                  let bStart = $1.startAt else {
                      return false
                  }
            return aStart < bStart
        })
        guard let event = sortedEvets.first else {
            return Event.error(text: "Coffee: The True Dark Lord")
        }
        return event
    }
}
