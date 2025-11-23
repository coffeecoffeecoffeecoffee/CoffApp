import SwiftUI

class UserProfile: ObservableObject {
    @Published private(set) var events: [Event] = []
    @Published private(set) var newEvents: [Event] = []
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

    @Published private(set) var groupIDs: Set<UUID> = []
    @AppStorage("encoded_group_ids", store: .sharedSuite) private var encodedGroupIDs: Data?
    @AppStorage("saved_events", store: .sharedSuite) private var savedEvents: Data?
    
    private var net = NetworkService.shared

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        try? load()
    }
}

// MARK: - Data Handling & Persistence
extension UserProfile {
    private func save() throws {
        encodedGroupIDs = try encoder.encode(groupIDs)
        savedEvents = try? encoder.encode(events)
    }

    private func load() throws {
        if let encodedGroupIDs,
              let decodedGroupIDs = try? decoder.decode(Set<UUID>.self,
                                                              from: encodedGroupIDs) {
            self.groupIDs = decodedGroupIDs
            self.hasGroups = !groupIDs.isEmpty
        }

        if let savedEvents,
           let oldEventsArray = try? decoder.decode([Event].self, from: savedEvents) {
            self.events = oldEventsArray
        }
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
        // Gotta defend against the server data changing…
        let existingGroups = try await syncGroups()
        
        // … before we fetch events.
        let allEventsForGroups = try await net.downloadAllEvents(for: existingGroups)
        return allEventsForGroups
    }

    func sync() async throws {
        let netEvents = try await allEvents()
        self.newEvents = netEvents.filter { event in
            !self.events.contains(where: {
                $0 == event
            })
        }
        self.events = netEvents
        self.upcomingEvents = events.upcoming()
        self.pastEvents = events.past()
        try save()
    }
    
    /// Merges the current client state with the server, automatically discarding
    /// groups that don’t exist on the server.
    /// - Returns: The `intersection of the server and user `InterestGroup.id`
    @discardableResult
    private func syncGroups() async throws -> Set<UUID> {
        let netGroupIDs = try await net.loadGroups().map { $0.id }
        let userGroupIDs = groupIDs
        groupIDs = userGroupIDs.intersection(netGroupIDs)
        guard groupIDs.isEmpty == false else {
            throw CoffeeErrors.syncError(reason: "No groups available")
        }
        return groupIDs
    }
}
