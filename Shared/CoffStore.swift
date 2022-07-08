import CoreData

protocol CoffStore {
    func loadSelectedInterestGroup(completionHandler: @escaping (Result<InterestGroup?, Error>) -> Void)
    func storeSelectedInterestGroup(_ interestGroup: InterestGroup, completionHandler: @escaping (Error?) -> Void)
    func loadEvents(completionHandler: @escaping (Result<Events, Error>) -> Void)
    func storeEvents(_ events: Events, completionHandler: @escaping (Error?) -> Void)
}

struct FilesystemCoffStore: CoffStore {
    enum Failure: Error {
        case noData(fileURL: URL)
    }
    let rootDirectoryURL: URL
    let fileManager: FileManager
    let queue = DispatchQueue(label: "coffee.CoffStore.serial-queue", attributes: .concurrent)

    var selectedInterestGroupFileURL: URL {
        rootDirectoryURL.appendingPathComponent("SelectedInterestGroup.json", isDirectory: false)
    }

    var eventsFileURL: URL {
        rootDirectoryURL.appendingPathComponent("SelectedInterestGroup.json", isDirectory: false)
    }

    static var defaultRootDirectoryURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let storeDirectoryURL = paths[0].appendingPathComponent("CoffStore", isDirectory: true)
        return storeDirectoryURL
    }

    init(rootDirectoryURL: URL? = nil, fileManager: FileManager = .default) {
        self.rootDirectoryURL =  rootDirectoryURL ?? FilesystemCoffStore.defaultRootDirectoryURL
        self.fileManager = fileManager
    }

    func loadSelectedInterestGroup(completionHandler: @escaping (Result<InterestGroup?, Error>) -> Void) {
        queue.async {
            do {
                let selectedInterestGroup = try load(fileURL: selectedInterestGroupFileURL, type: InterestGroup.self)
                completionHandler(.success(selectedInterestGroup))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }

    func storeSelectedInterestGroup(_ interestGroup: InterestGroup, completionHandler: @escaping (Error?) -> Void) {
        queue.async(flags: .barrier) {
            do {
                try store(fileURL: selectedInterestGroupFileURL, value: interestGroup)
                completionHandler(nil)
            } catch {
                completionHandler(error)
            }
        }
    }

    func loadEvents(completionHandler: @escaping (Result<Events, Error>) -> Void) {
        queue.async {
            do {
                let events = try load(fileURL: eventsFileURL, type: Events.self) ?? []
                completionHandler(.success(events))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }

    func storeEvents(_ events: Events, completionHandler: @escaping (Error?) -> Void) {
        queue.async(flags: .barrier) {
            do {
                try store(fileURL: eventsFileURL, value: events)
                completionHandler(nil)
            } catch {
                completionHandler(error)
            }
        }
    }

    private func load<T>(fileURL: URL, type: T.Type) throws -> T? where T: Decodable {
        dispatchPrecondition(condition: .notOnQueue(.main))
        dispatchPrecondition(condition: .onQueue(queue))

        if !fileManager.fileExists(atPath: fileURL.path) {
            // No data has been stored yet or it was deleted
            return nil
        }
        guard let jsonData = fileManager.contents(atPath: fileURL.path) else {
            // automatically delete an invalid file
            try? fileManager.removeItem(at: fileURL)
            throw Failure.noData(fileURL: fileURL)
        }
        let instance = try JSONDecoder().decode(type.self, from: jsonData)
        return instance
    }

    private func store<T>(fileURL: URL, value: T) throws  where T: Encodable {
        dispatchPrecondition(condition: .notOnQueue(.main))
        dispatchPrecondition(condition: .onQueue(queue))

        let jsonData = try JSONEncoder().encode(value)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
        try jsonData.write(to: fileURL)
    }

}

var defaultCoffeStore: CoffStore?

extension CoffStore {
    static var `default`: CoffStore {
        if let coffStore = defaultCoffeStore {
            return coffStore
        } else {
            let coffStore = FilesystemCoffStore()
            defaultCoffeStore = coffStore
            return coffStore
        }
    }
}
