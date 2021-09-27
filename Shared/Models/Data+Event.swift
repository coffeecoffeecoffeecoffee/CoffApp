import Foundation

extension Data {
    enum Errors: Error {
        case noURL
        case noLocalAsset(String)
    }

    init(contentsOf url: URL?) throws {
        guard let unwrappedURL = url else { throw Errors.noURL }
        self = try Data(contentsOf: unwrappedURL)
    }

    static func imageData(for event: Event) throws -> Data {
        var data: Data!
        do {
            data = try Data(contentsOf: event.imageURL)
        } catch {
            let coffeeImageName = "coffee-\(Int.random(in: 1...10))"
            guard let localCoffeeImageURL = Bundle.main.url(forResource: coffeeImageName, withExtension: "jpeg") else {
                throw Errors.noLocalAsset(coffeeImageName)
            }
            data = try Data(contentsOf: localCoffeeImageURL)
        }
        return data
    }
}
