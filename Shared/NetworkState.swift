import Foundation
enum NetworkState {
    case ready
    case loading
    case failed(Error)
}

extension NetworkState: CustomStringConvertible {
    var description: String {
        switch self {
        case .ready:
            return NSLocalizedString("Ready", comment: "Shown when the network is ready")
        case .loading:
            return NSLocalizedString("Loading…", comment: "Shown when the network is busy")
        case .failed(let error):
            return error.localizedDescription
        }
    }
}
