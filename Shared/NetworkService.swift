import Combine
import Foundation
import Logging

final class NetworkService: ObservableObject {
    @Published var groups = [Group]()
    @Published var events = [Event]()
    @Published var upcomingEvents = [Event]()
    @Published var pastEvents = [Event]()
    @Published var netState = NetworkState.loading
    private var logger = Logger(label: Bundle.main.bundleIdentifier!
                                    .appending(".loggers"))
    private var subscribers = Set<AnyCancellable>()
    private var session = URLSession.shared
    private var decoder = JSONDecoder()

    private let groupURL = URL(string: "https://coffeecoffeecoffee.coffee/api/groups/")!

    enum NetworkError: Error {
        case invalidURL
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

    func cancelAll() {
        subscribers.removeAll()
        self.netState = .ready
    }

    init() {
        decoder.dateDecodingStrategy = .iso8601
        loadGroups()
    }
}

// MARK: - Groups
extension NetworkService {
    func loadGroups() {
        netState = .loading
        session.dataTaskPublisher(for: groupURL)
            .retry(5)
            .map { $0.data }
            .decode(type: [Group].self, decoder: decoder)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else {
                    self?.logger.error("loadGroup() no self")
                    self?.netState = .failed(NetworkError.unknownError)
                    return
                }
                switch completion {
                case .failure(let error):
                    self.logger.critical("Network Error \n\(error.localizedDescription)")
                    self.netState = .failed(error)
                case .finished:
                    self.logger.debug("Group Fetch Complete")
                    self.netState = .ready
                }
            } receiveValue: { netGroups in
                self.logger.debug("fetched groups \n\(netGroups.count)")
                self.groups = netGroups
            }
            .store(in: &subscribers)
    }
}

// MARK: - Events
extension NetworkService {
    func loadEvents(for group: Group) {
        guard let url = group.eventsURL else {
            self.netState = .failed(NetworkError.invalidURL)
            return
        }
        netState = .loading
        session.dataTaskPublisher(for: url)
            .retry(5)
            .map {
                $0.data
            }
            .decode(type: [Event].self, decoder: decoder)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else {
                    self?.logger.error("loadEvents() - no self")
                    self?.netState = .failed(NetworkError.unknownError)
                    return
                }
                switch completion {
                case .failure(let error):
                    self.logger.critical("Network Error\n\(error.localizedDescription)")
                    self.netState = .failed(error)
                case .finished:
                    self.logger.info("Events fetch complete")
                    self.netState = .ready
                }
            } receiveValue: { netEvents in
                self.logger.info("Events loaded: \(netEvents.count)")
                self.events = netEvents
            }
            .store(in: &subscribers)
    }
}
