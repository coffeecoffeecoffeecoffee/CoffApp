import CoffeeKit
import Foundation
import Observation
import SwiftData

@Observable
final class UserProfile {
    private(set) var events: [Event] = []
    private(set) var newEvents: [Event] = []
    private(set) var filteredEvents = [Event]()
    private(set) var upcomingEvents: [Event] = []
    private(set) var pastEvents: [Event] = []
    private(set) var hasGroups: Bool = false
    var queryString: String = "" {
        didSet {
            let newEvents = try? events.matching(term: queryString)
            filteredEvents = newEvents ?? []
        }
    }

    private(set) var groupIDs: Set<UUID> = []
    private var encodedGroupIDs: Data?
    private var savedEvents: Data?
    
    private var net: NetworkServicing
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(net: NetworkServicing) {
        self.net = net
        try? load()
    }
}

// MARK: - Data Handling & Persistence
extension UserProfile {
    public func storeEvents(for groups: [InterestGroup], modelContext: ModelContext) async throws {
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for group in groups {
                guard let groupID = group.id else { continue }
                taskGroup.addTask { [self, modelContext] in
                    // Create a background context per task for thread safety
                    let bgContext = ModelContext(modelContext.container)
                    bgContext.autosaveEnabled = false

                    // Fetch (or create) the InterestGroupModel by id
                    let groupDescriptor = FetchDescriptor<InterestGroupModel>(
                        predicate: #Predicate { $0.id == groupID }
                    )

                    let groupModel: InterestGroupModel
                    if let existing = try bgContext.fetch(groupDescriptor).first {
                        groupModel = existing
                    } else {
                        let newModel = InterestGroupModel(id: groupID,
                                                          name: group.name,
                                                          imageURL: group.imageURL,
                                                          short: group.short
                        )
                        bgContext.insert(newModel)
                        groupModel = newModel
                    }

                    // Download all events for this group
                    let fetchedEvents = try await net.loadEvents(for: group)

                    guard let groupID = group.id else {
                        throw CoffeeErrors.invalid(reason: "No id for group: \(group.name)")
                    }
                    // Fetch existing EventModel instances for this group to upsert
                    let existingEventsDescriptor = FetchDescriptor<EventModel>(
                        predicate: #Predicate { $0.groupID == groupID }
                    )
                    let existingModels = try bgContext.fetch(existingEventsDescriptor)
                    let existingByID: [UUID: EventModel] = Dictionary(
                        uniqueKeysWithValues: existingModels.map { ($0.id, $0) }
                    )

                    // Upsert and maintain relationship
                    for event in fetchedEvents {
                        guard let id = event.id else { continue }
                        if let model = existingByID[id] {
                            if model.name != event.name { model.name = event.name }
                            if model.imageURL != event.imageURL { model.imageURL = event.imageURL }
                            if model.startAt != event.startAt { model.startAt = event.startAt }
                            if model.endAt != event.endAt { model.endAt = event.endAt }
                            if model.venue != event.venue { model.venue = event.venue }
                            if model.groupID != group.id { model.groupID = groupID }
                            if model.group?.id != groupModel.id { model.group = groupModel }
                        } else {
                            guard let newModel = EventModel(event) else { continue }
                            newModel.groupID = groupID
                            newModel.group = groupModel
                            bgContext.insert(newModel)
                        }
                    }

                    // Persist changes for this group
                    try bgContext.save()
                }
            }

            // Wait for all tasks to complete or throw
            try await taskGroup.waitForAll()
        }
    }
    
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

    func subscribedTo(_ group: InterestGroupRepresentable) throws -> Bool {
        guard let groupID = group.id else {
            throw CoffeeErrors.invalid(reason: "Group does not contain ID: \(group.name)")
        }
        return self.groupIDs.contains(groupID)
    }

    func toggleGroup(_ group: InterestGroupRepresentable) throws {
        guard let groupID = group.id else {
            throw CoffeeErrors.invalid(reason: "Group does not contain ID: \(group.name)")
        }
        if try subscribedTo(group) {
            self.groupIDs.remove(groupID)
        } else {
            self.groupIDs.insert(groupID)
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
        let netGroupIDs: [UUID] = try await net.loadGroups().compactMap { $0.id }
        let userGroupIDs = groupIDs
        groupIDs = userGroupIDs.union(netGroupIDs)
        guard groupIDs.isEmpty == false else {
            throw CoffeeErrors.syncError(reason: "No groups available")
        }
        return groupIDs
    }
}
