import Foundation

enum NetworkError: Error {
    case invalidURL
    case noSelectedInterestGroup
    case unknownError

    var description: String {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid Group URL", comment: "")
        default:
            return NSLocalizedString("Unkown error", comment: "")
        }
    }
}
