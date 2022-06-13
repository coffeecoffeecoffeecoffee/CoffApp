import SwiftUI

class UserProfile: ObservableObject {
    @Published private(set) var events: [Event] = []
    @Published private(set) var filteredEvents = [Event]()
    @Published private(set) var upcomingEvents: [Event] = []
    @Published private(set) var pastEvents: [Event] = []
    @Published private(set) var hasGroups: Bool = false
    @Published var queryString: String = "" {
        didSet {
            let newEvents = try? events.matching(term: queryString)
            filteredEvents = newEvents ?? []
        }
    }

    private var groupIDs: Set<UUID> = []
    @AppStorage("encoded_group_ids", store: .sharedSuite) private var encodedGroupIDs: Data?
    private var net = NetworkService.shared

    init() {
        guard let encodedGroupIDs,
              let decodedGroupIDs = try? JSONDecoder().decode(Set<UUID>.self, from: encodedGroupIDs)
        else { return }
        self.groupIDs = decodedGroupIDs
        self.hasGroups = !groupIDs.isEmpty
    }
}

// MARK: - Data Handling & Persistence
extension UserProfile {
    private func save() throws {
        encodedGroupIDs = try JSONEncoder().encode(groupIDs)
    }

    func subscribedTo(_ group: InterestGroup) -> Bool {
        self.groupIDs.contains(group.id)
    }

    func toggleGroup(_ group: InterestGroup) throws {
        if subscribedTo(group) {
            self.groupIDs.remove(group.id)
        } else {
            self.groupIDs.insert(group.id)
        }
        self.hasGroups = !groupIDs.isEmpty
        try save()
        Task {
            try await sync()
        }
    }
}

// MARK: - Networking
@MainActor
extension UserProfile {
    private func allEvents() async throws -> [Event] {
        try await net.downloadAllEvents(for: groupIDs)
    }

    func sync() async throws {
        self.events = try await allEvents()
        self.upcomingEvents = events.upcoming()
        self.pastEvents = events.past()
    }
}
