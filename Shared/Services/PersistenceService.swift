//
//  PeristenceService.swift
//  CoffApp
//
//  Created by Michael Critz on 11/21/25.
//

import Foundation
import SwiftData

final class PersistenceService: ObservableObject {
    /// Replaces all occurrences of InterestGroupModel in the store with the provided groups, matching on id
    static func update(interestGroups: [InterestGroup], modelContext: ModelContext) throws {
        // Fetch existing persisted groups
        let descriptor = FetchDescriptor<InterestGroupModel>()
        var existing = try modelContext.fetch(descriptor)

        // Index incoming by id for quick lookups
        let incomingByID = Dictionary(uniqueKeysWithValues: interestGroups.map { ($0.id, $0) })
        let incomingIDs = Set(incomingByID.keys)

        // Delete any persisted groups not present in the incoming set
        for groupModel in existing where !incomingIDs.contains(groupModel.id) {
            modelContext.delete(groupModel)
        }

        // Refresh existing after deletions to ensure consistency
        existing = try modelContext.fetch(descriptor)

        // Update models that exist in both sets
        for model in existing {
            if let incoming = incomingByID[model.id] {
                // Only write if values differ to minimize change tracking
                if model.name != incoming.name { model.name = incoming.name }
                if model.imageURL != incoming.imageURL { model.imageURL = incoming.imageURL }
            }
        }

        // Insert any new groups that don't exist yet
        let existingIDs = Set(existing.map { $0.id })
        let newGroups = interestGroups.filter { !existingIDs.contains($0.id) }
        for newGroup in newGroups {
            let model = InterestGroupModel(id: newGroup.id,
                                           name: newGroup.name,
                                           imageURL: newGroup.imageURL,
                                           short: newGroup.short,
                                           isArchived: newGroup.isArchived,
            )
            modelContext.insert(model)
        }

        // Persist all changes
        try modelContext.save()
    }
    
    /// Replaces all `Events` per `InterestGroup` with the new array
    static func replace(events: [Event], for groupID: UUID, in modelContext: ModelContext) throws {
        // Fetch existing EventModel objects for this group
        let descriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate { model in
                model.groupID == groupID
            }
        )
        var existing = try modelContext.fetch(descriptor)

        // Build incoming lookup and id set (defend against duplicate ids)
        let incomingByID: [UUID?: Event] = Dictionary(
            events.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let incomingIDs = Set(incomingByID.keys)

        // Delete any existing events not present in the incoming set (also remove models with nil ids)
        for model in existing {
            if !incomingIDs.contains(model.id) {
                modelContext.delete(model)
            }
        }

        // Refresh existing after deletions for consistency
        existing = try modelContext.fetch(descriptor)
        let existingByID: [UUID: EventModel] = Dictionary(
            uniqueKeysWithValues: existing.compactMap { model in
                return (model.id, model)
            }
        )

        // Update existing or insert new events
        for (id, incoming) in incomingByID {
            guard let id else { continue }
            if let model = existingByID[id] {
                if model.groupID != groupID { model.groupID = groupID }
                if model.name != incoming.name { model.name = incoming.name }
                if model.imageURL != incoming.imageURL { model.imageURL = incoming.imageURL }
                if model.startAt != incoming.startAt { model.startAt = incoming.startAt }
                if model.endAt != incoming.endAt { model.endAt = incoming.endAt }
                if model.venue != incoming.venue { model.venue = incoming.venue }
            } else {
                guard let newModel = EventModel(incoming) else { continue }
                newModel.groupID = groupID
                modelContext.insert(newModel)
            }
        }

        // Persist changes
        try modelContext.save()
    }
    
    /// Upserts the contents of events array with the existing events for an ``InterestGroupModel``.
    /// Existing ``EventModel`` properties are updated with any matching ``Event`` with the same id.
    /// New ``EventModel``s are saved with an association to the ``InterestGroupModel`` that matches the
    /// ``Event``’s  .groupID
    static func merge(events: [Event], for groupID: UUID, in modelContext: ModelContext) throws {
        // Fetch existing EventModel objects for this group
        let eventModelDescriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate { model in
                model.groupID == groupID
            }
        )
        let existingEventModels = try modelContext.fetch(eventModelDescriptor)
        let existingByID: [UUID: EventModel] = Dictionary(
            uniqueKeysWithValues: existingEventModels.compactMap { model in
                return (model.id, model)
            }
        )

        // Deduplicate incoming by id and upsert
        let incomingByID: [UUID?: Event] = Dictionary(
            events.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        for (id, incoming) in incomingByID {
            guard let id,
                  let targetGroupID = incoming.groupID else { continue }
            if let model = existingByID[id] {
                if model.groupID != targetGroupID { model.groupID = targetGroupID }
                if model.name != incoming.name { model.name = incoming.name }
                if model.imageURL != incoming.imageURL { model.imageURL = incoming.imageURL }
                if model.startAt != incoming.startAt { model.startAt = incoming.startAt }
                if model.endAt != incoming.endAt { model.endAt = incoming.endAt }
                if model.venue != incoming.venue { model.venue = incoming.venue }
            } else {
                guard let newModel = EventModel(incoming) else { continue }
                newModel.groupID = targetGroupID
                modelContext.insert(newModel)
            }
        }

        // Persist changes
        try modelContext.save()
    }
}
