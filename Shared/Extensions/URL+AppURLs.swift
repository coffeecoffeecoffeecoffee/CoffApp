import Foundation

extension URL {
    static var baseURL = URL(string: "https://www.coffeecoffeecoffee.coffee")!

    static func appURL(with paths: String...) -> URL {
        var url = URL.baseURL
        paths.forEach { path in
            url = url.appendingPathComponent(path)
        }
        return url
    }
}
