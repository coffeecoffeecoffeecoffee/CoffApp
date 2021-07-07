import Foundation

struct Location: Codable {
    let latitude, longitude: Double?
}

extension Location: Hashable { }
