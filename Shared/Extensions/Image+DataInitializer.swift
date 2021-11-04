import Foundation
import SwiftUI

extension Image {
    enum Errors: Error {
        case invalidData(reason: String)
    }

    init(data: Data) throws {
        #if os(macOS) // NSImage
        guard let nsImage = NSImage(data: data) else {
            throw Errors.invalidData(reason: "Not valid NSImage data")
        }
        self = Image(nsImage: nsImage)
        #else // UIImage
        guard let uiImage = UIImage(data: data) else {
            throw Errors.invalidData(reason: "Not valid UIImage data")
        }
        self = Image(uiImage: uiImage)
        #endif
    }
}
