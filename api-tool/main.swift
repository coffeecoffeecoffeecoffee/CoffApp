import Foundation

struct ApiTool {
    static var baseURL = URL(string: "https://coffeecoffeecoffee.coffee/api/")!
    static var groupsURL = { baseURL.appendingPathComponent("groups/") }
    static func url(for group: Group) -> URL {
        groupsURL().appendingPathComponent(group.id.uuidString)
    }
    let decoder = JSONDecoder()
    let encoder: JSONEncoder

    init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        decoder.dateDecodingStrategy = .iso8601
    }

    func fetch<T: Codable>(_ url: URL, type: T) throws -> T {
        let data = try Data(contentsOf: url)
        let decoded = try decoder.decode(T.self, from: data)
        return decoded
    }

    func encode<T: Codable>(_ content: T) throws -> Data {
        try encoder.encode(content)
    }

    func write(_ data: Data, url: URL) throws {
        try data.write(to: url)
    }

    func main() throws {
        let outputDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("/coffee-data/")
        print("Saving to \(outputDirectory)")
        try FileManager.default.createDirectory(at: outputDirectory,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        let groups = try fetch(ApiTool.groupsURL(), type: [Group]())
        try write(try encode(groups),
                  url: outputDirectory.appendingPathComponent("groups.json"))
        try groups.forEach { group in
            try write(try encode(group),
                      url: outputDirectory.appendingPathComponent(group.name.appending(".json")))
            guard let groupEventsURL = group.eventsURL else {
                print("No events for \(group.name)")
                return
            }
            let events = try fetch(groupEventsURL, type: [Event]())
            try write(try encode(events),
                      url: outputDirectory.appendingPathComponent("events-\(group.name).json"))
            try events.forEach { event in
                guard let imageURL = event.imageURL else { return }
                let imageData = try Data(contentsOf: imageURL)
                do {
                    try imageData.write(to: outputDirectory.appendingPathComponent(imageURL.lastPathComponent))
                } catch {
                    print(error)
                }
            }
        }
    }
}

try ApiTool().main()
