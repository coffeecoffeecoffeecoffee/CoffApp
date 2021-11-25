import Foundation

enum NetworkState {
    case ready(description: String)
    case loading
    case failed(Error)
}

extension NetworkState: Equatable {
    static func == (lhs: NetworkState, rhs: NetworkState) -> Bool {
        lhs.description == rhs.description
    }
}

extension NetworkState: CustomStringConvertible {
    var description: String {
        switch self {
        case .ready(let updated):
            return "Updated: \(updated)"
        case .loading:
            return NSLocalizedString("Loading…", comment: "Shown when the network is busy")
        case .failed(let error):
            return error.localizedDescription
        }
    }
}
