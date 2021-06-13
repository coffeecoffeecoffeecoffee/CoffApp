import Foundation
import Logging

struct ImageCache {
    static func save(_ imageData: Data, for url: URL) {
        let logger = Logger(label: Bundle.main.bundleIdentifier!
                                        .appending(".imagecache.log"))
        let tmp = FileManager.default.temporaryDirectory

        if FileManager.default.fileExists(atPath: tmp.appendingPathComponent(url.lastPathComponent).path) {
            logger.info("cache exists: \(url.lastPathComponent)")
            return
        }

        do {
            try imageData.write(to: tmp.appendingPathComponent(url.lastPathComponent))
            logger.info("cache writing: \(url.lastPathComponent)")
        } catch let fileError {
            logger.critical(Logger.Message(stringLiteral: fileError.localizedDescription))
        }
    }

    static func fetchData(for url: URL) -> Data? {
        let logger = Logger(label: Bundle.main.bundleIdentifier!
                                        .appending(".imagecache.log"))
        logger.info("cache lookup: \(url.lastPathComponent)")
        let cacheURL = FileManager.default
                .temporaryDirectory
                .appendingPathComponent(url.lastPathComponent)
        guard let data = FileManager.default.contents(atPath: cacheURL.path) else {
            logger.info("cache miss for \(url.lastPathComponent)")
            return nil
        }
        logger.info("got data for: \(url.lastPathComponent)")
        return data
    }
}
