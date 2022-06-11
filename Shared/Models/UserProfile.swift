import SwiftUI

@MainActor
class UserProfile: ObservableObject {
    @Published var events: [Event] = [] {
        didSet {
            upcomingEvents = events.upcoming()
            pastEvents = events.past()
        }
    }
    @Published var upcomingEvents: [Event] = []
    @Published var pastEvents: [Event] = []
    @Published var hasGroups: Bool = false

    private var groupIDs: Set<UUID> = []
    @AppStorage("encoded_group_ids", store: .standard) private var encodedGroupIDs: Data?
    private var net = NetworkService.shared

    init() {
        guard let encodedGroupIDs,
              let decodedGroupIDs = try? JSONDecoder().decode(Set<UUID>.self, from: encodedGroupIDs)
        else { return }
        self.groupIDs = decodedGroupIDs
        self.hasGroups = !groupIDs.isEmpty
        Task {
            self.events = try await allEvents()
        }
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
            try removeGroup(group)
        } else {
            try addGroup(group)
        }
    }

    func addGroup(_ newGroup: InterestGroup) throws {
        self.groupIDs.insert(newGroup.id)
        try save()
    }

    func removeGroup(_ groupToDelete: InterestGroup) throws {
        self.groupIDs.remove(groupToDelete.id)
        try save()
    }
}

// MARK: - Networking
extension UserProfile {
    func allEvents() async throws -> [Event] {
        try await net.downloadAllEvents(for: groupIDs)
    }
}
