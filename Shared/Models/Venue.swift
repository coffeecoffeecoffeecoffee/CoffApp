import Foundation.NSUUID

struct Venue: Codable, Identifiable {
    let id: UUID?
    let name: String
    let location: Location?
    
    init(id: UUID? = nil, name: String, location: Location?) {
        self.id = id
        self.name = name
        self.location = location
    }
}

extension Venue: Hashable {
    static func == (lhs: Venue, rhs: Venue) -> Bool {
        lhs.name == rhs.name
    }
}

extension Venue {
    func getDirections() {
        location?.getDirections(name)
    }
}
