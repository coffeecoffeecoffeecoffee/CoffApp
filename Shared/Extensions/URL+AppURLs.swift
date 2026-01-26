import Foundation

extension URL {
    #if false
    static let baseURL = URL(string: "http://localhost:8080")!
    #else
    static let baseURL = URL(string: "https://www.coffeecoffeecoffee.coffee")!
    #endif
    
    static func appURL(with paths: String...) -> URL {
        var url = URL.baseURL
        paths.forEach { path in
            url = url.appendingPathComponent(path)
        }
        return url
    }
    
    static func apiV2(with paths: String...) -> URL {
        var url = URL.appURL(with: "api", "v2")
        for path in paths {
            url = url.appendingPathComponent(path)
        }
        return url
    }
    
    static let groupsURL = Self.apiV2(with: "groups")
    static let venuesURL = Self.apiV2(with: "venues")

    static func eventsURL(for id: UUID) -> URL {
        appURL(with: "api", "v2", "groups", id.uuidString.lowercased(), "events")
    }
}
