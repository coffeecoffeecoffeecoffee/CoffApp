import Foundation

struct Location: Codable {
    let title: String
    let latitude, longitude: Double?
}

extension Location: Hashable { }
