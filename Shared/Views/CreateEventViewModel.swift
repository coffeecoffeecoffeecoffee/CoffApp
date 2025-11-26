//
//  CreateEventViewModel.swift
//  CoffApp
//
//  Created by Michael Critz on 11/26/25.
//

import Foundation
import Observation

@Observable
final class CreateEventViewModel {
    public var eventName: String = ""
    public var startAt: Date
    public var endAt: Date
    public var selectedVenue: Venue?
    public var venues = [Venue]()
    public var selectedGroup: InterestGroup?
    public var groups = [InterestGroup]()
    
    private let net = NetworkService.shared
    
    init() {
        startAt = .now.adding(2, component: .day)?.rounded(to: .hour)
            ?? .now.advanced(by: 120).rounded()
        endAt = .now
            .adding(2, component: .day)?
            .adding(2, component: .hour)?
            .rounded()
            ?? .now
            .advanced(by: 240)
            .rounded()
    }
    
    public func fetchVenues() async {
        do {
            venues = try await net.loadVenues().compactMap { venue in
                guard venue.id != nil,
                      venue.location != nil
                else {
                    return nil
                }
                return venue
            }
        } catch {
            // TODO: handle failure
            print(error.localizedDescription)
        }
    }
    
    public func fetchGroups() async {
        do {
            groups = try await net.loadGroups()
        } catch {
            // TODO: handle failure here, too
            print(error.localizedDescription)
        }
    }
    
    @discardableResult
    public func createEvent() async -> Result<Event, CoffeeErrors> {
        guard eventName.isEmpty == false,
              let selectedVenue,
              let selectedGroup
        else {
            return .failure(CoffeeErrors.invalid(reason: "Missing required fields"))
        }
        let event = Event(id: UUID(),
                          name: eventName,
                          groupID: selectedGroup.id,
                          venue: selectedVenue,
                          imageURL: nil,
                          startAt: startAt,
                          endAt: endAt)
        let result = await net.createEvent(event)
        return result
    }
}

