//
//  PreviewNetworkService.swift
//  CoffApp
//
//  Created by Michael Critz on 11/26/25.
//

import CoffeeKit
import Foundation
import Observation

@Observable
final class PreviewNetworkService: NetworkServicing {
    // State required by protocol
    var groups: [InterestGroup] = [
        InterestGroup(id: UUID(uuidString: "11111111-1111-4111-1111-111111111111")!,
                      name: "Coffee Lovers",
                      imageURL: nil,
                      short: "coffee-lovers",
                     ),
        InterestGroup(id: UUID(uuidString: "22222222-2222-4222-2222-222222222222")!,
                      name: "Espresso Enthusiasts",
                      imageURL: nil,
                      short: "espressos",
                     )
    ]

    var events: [Event] = [] {
        didSet {
            upcomingEvents = events.upcoming()
            pastEvents = events.past()
        }
    }

    var upcomingEvents: [Event] = []
    var pastEvents: [Event] = []
    var netState: NetworkState = .ready

    init() {
        // Seed some sample events for previews
        let now = Date()
        let venue = Venue(name: "Preview Cafe",
                          location: Location(title: "Main St.",
                                             latitude: 37.7749,
                                             longitude: -122.4194))
        let imgURL = "https://example.com/image.jpg"

        let sampleEvents: [Event] = [
            Event(id: UUID(),
                  name: "Morning Pour Over",
                  groupID: groups[0].id,
                  venue: venue,
                  imageURL: imgURL,
                  startAt: now.addingTimeInterval(3600),
                  endAt: now.addingTimeInterval(7200)),
            Event(id: UUID(),
                  name: "Latte Art Jam",
                  groupID: groups[1].id,
                  venue: venue,
                  imageURL: imgURL,
                  startAt: now.addingTimeInterval(-7200),
                  endAt: now.addingTimeInterval(-3600))
        ]
        self.events = sampleEvents
    }

    // Lifecycle
    func cancelAll() {
        events = []
        upcomingEvents = []
        pastEvents = []
        netState = .ready
    }

    // Auth (stubbed for previews)
    func jwtHeader() throws -> String { "Bearer preview-token" }

    func signIn(_ email: String, password: String) async -> Result<String, CoffeeErrors> {
        .success("Signed in (preview)")
    }

    func retrieveJWT(localizedReason: String) throws -> String { "preview-jwt" }
    func retrieveEmail(localizedReason: String) throws -> String { "preview@example.com" }
    func retrievePassword(localizedReason: String) throws -> String { "password" }

    // Data Loading
    func loadVenues() async throws -> [Venue] {
        [
            Venue(name: "Preview Cafe",
                  location: Location(title: "Main St.", latitude: 37.7749, longitude: -122.4194))
        ]
    }

    func loadGroups() async throws -> [InterestGroup] { groups }

    func loadEvents(for group: InterestGroup) async throws -> [Event] {
        events.filter { $0.groupID == group.id }
    }

    func loadAllEvents(for groups: [InterestGroup]) async throws -> [InterestGroup: [Event]] {
        var dict: [InterestGroup: [Event]] = [:]
        for g in groups {
            dict[g] = try await loadEvents(for: g)
        }
        return dict
    }

    // TODO: Actually download stuff
    func downloadAllEvents(for groupIDs: Set<UUID>) async throws -> [Event] {
        events.filter {
            if let groupID = $0.groupID {
                return groupIDs.contains(groupID)
            }
            return false
        }
    }

    // Mutations
    func createEvent(_ event: Event) async -> Result<Event, CoffeeErrors> {
        events.append(event)
        return .success(event)
    }
}
