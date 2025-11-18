import Foundation

extension URL {
    #if true
    static let baseURL = URL(string: "https://coffeecoffee.world")!
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

    static func groupURL(_ id: UUID) -> URL {
        appURL(with: "api", "v2", "groups", id.uuidString.lowercased(), "events")
    }
}
