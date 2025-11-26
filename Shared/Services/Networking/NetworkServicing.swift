//
//  NetworkServicing.swift
//  CoffApp
//
//  Created by Michael Critz on 11/26/25.
//

import Foundation.NSUUID

protocol NetworkServicing {
    // State
    var groups: [InterestGroup] { get set }
    var events: [Event] { get set }
    var upcomingEvents: [Event] { get }
    var pastEvents: [Event] { get }
    var netState: NetworkState { get set }

    // Lifecycle
    func cancelAll()

    // Auth
    func jwtHeader() throws -> String
    func signIn(_ email: String, password: String) async -> Result<String, CoffeeErrors>
    func retrieveJWT(localizedReason: String) throws -> String
    func retrieveEmail(localizedReason: String) throws -> String
    func retrievePassword(localizedReason: String) throws -> String

    // Data Loading
    func loadVenues() async throws -> [Venue]
    func loadGroups() async throws -> [InterestGroup]
    func loadEvents(for group: InterestGroup) async throws -> [Event]
    func loadAllEvents(for groups: [InterestGroup]) async throws -> [InterestGroup: [Event]]
    func downloadAllEvents(for groupIDs: Set<UUID>) async throws -> [Event]

    // Mutations
    func createEvent(_ event: Event) async -> Result<Event, CoffeeErrors>
}
