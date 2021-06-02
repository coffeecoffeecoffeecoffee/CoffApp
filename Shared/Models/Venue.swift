struct Venue: Codable {
    let name: String?
    let location: Location?
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
