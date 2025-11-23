import Combine
import Logging
import SwiftUI
import SwiftData

struct GroupListView: View {
    @EnvironmentObject var profile: UserProfile
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor<InterestGroupModel>(\.name, order: .forward)])
    private var groups: [InterestGroupModel]
    private let net = NetworkService.shared
    
    private let logger = Logger(label: "GroupListView.logger")
    
    private func storeEvents(for groups: [InterestGroup]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for group in groups {
                taskGroup.addTask { [net, modelContext] in
                    // Create a background context per task for thread safety
                    let bgContext = ModelContext(modelContext.container)
                    bgContext.autosaveEnabled = false

                    // Fetch (or create) the InterestGroupModel by id
                    let groupDescriptor = FetchDescriptor<InterestGroupModel>(
                        predicate: #Predicate { $0.id == group.id }
                    )

                    let groupModel: InterestGroupModel
                    if let existing = try bgContext.fetch(groupDescriptor).first {
                        groupModel = existing
                    } else {
                        let newModel = InterestGroupModel(id: group.id,
                                                          name: group.name,
                                                          imageURL: group.imageURL)
                        bgContext.insert(newModel)
                        groupModel = newModel
                    }

                    // Download all events for this group
                    let fetchedEvents = try await net.loadEvents(for: group)

                    // Fetch existing EventModel instances for this group to upsert
                    let existingEventsDescriptor = FetchDescriptor<EventModel>(
                        predicate: #Predicate { $0.groupID == group.id }
                    )
                    let existingModels = try bgContext.fetch(existingEventsDescriptor)
                    var existingByID: [UUID: EventModel] = Dictionary(
                        uniqueKeysWithValues: existingModels.map { ($0.id, $0) }
                    )

                    // Upsert and maintain relationship
                    for event in fetchedEvents {
                        if let model = existingByID[event.id] {
                            if model.name != event.name { model.name = event.name }
                            if model.imageURL != event.imageURL { model.imageURL = event.imageURL }
                            if model.startAt != event.startAt { model.startAt = event.startAt }
                            if model.endAt != event.endAt { model.endAt = event.endAt }
                            if model.venue != event.venue { model.venue = event.venue }
                            if model.groupID != group.id { model.groupID = group.id }
                            if model.group?.id != groupModel.id { model.group = groupModel }
                        } else {
                            let newModel = EventModel(event)
                            newModel.groupID = group.id
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
    
    private func interestGroups(matchingIDs groupIDs: Set<UUID>) -> [InterestGroup] {
        groups.compactMap { groupModel in
            guard let _ = groupIDs.first(where: {
                groupModel.id == $0
            }) else {
                return nil
            }
            return InterestGroup(id: groupModel.id,
                                 name: groupModel.name,
                                 imageURL: groupModel.imageURL
            )
        }
    }

    var body: some View {
        List(groups) { groupModel in
            HStack {
                let proxy = InterestGroup(id: groupModel.id, name: groupModel.name, imageURL: groupModel.imageURL)
                let iconName = profile.subscribedTo(proxy) ? "checkmark.circle.fill" : "circle"
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                Text(groupModel.name)
            }
            .onTapGesture {
                let proxy = InterestGroup(id: groupModel.id, name: groupModel.name, imageURL: groupModel.imageURL)
                do {
                    try profile.toggleGroup(proxy)
                    let subscribedGroupIDs = profile.groupIDs
                    let subscribedGroups = interestGroups(matchingIDs: subscribedGroupIDs)
                    Task {
                        try await storeEvents(for: subscribedGroups)
                    }
                } catch {
                    logger.error(.init(stringLiteral: error.localizedDescription))
                }
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GroupListView()
            .environmentObject(UserProfile())
    }
}
#endif

