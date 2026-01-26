import CoffeeKit
import Foundation

public typealias Venue = VenuePublic

//struct Venue: VenueRepresentable, Codable, Identifiable {
//    let id: UUID?
//    let name: String
//    let location: Location?
//    
//    init(id: UUID? = nil, name: String, location: Location?) {
//        self.id = id
//        self.name = name
//        self.location = location
//    }
//}

extension Venue {
    public func getDirections() {
        location?.getDirections(name)
    }
}
