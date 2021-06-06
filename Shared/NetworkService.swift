import Combine
import Foundation
import Logging

final class NetworkService: ObservableObject {
    @Published var groups = [Group]()
    @Published var events = [Event]()
    let eventsSubject = PassthroughSubject<[Event], Error>()
    @Published var firstEvent: Event = Event.loading
    @Published var upcomingEvents = [Event]()
    @Published var pastEvents = [Event]()
    @Published var netState = NetworkState.loading
    private var logger = Logger(label: Bundle.main.bundleIdentifier!
                                    .appending("NetworkService.log"))
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
        logger.info("Loading all groups")
        session.dataTaskPublisher(for: groupURL)
            .retry(2)
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
    func loadAllEvents(for group: Group) -> AnyPublisher<[Event], Error> {
        guard let url = group.eventsURL else {
            self.netState = .failed(NetworkError.invalidURL)
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        netState = .loading
        return session.dataTaskPublisher(for: url)
            .retry(5)
            .map {
                $0.data
            }
            .decode(type: [Event].self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    func loadEvents(for group: Group) {
        loadAllEvents(for: group)
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
                    self.sort([Event.error])
                case .finished:
                    self.logger.info("Events fetch complete")
                    self.netState = .ready
                }
            } receiveValue: { netEvents in
                self.logger.info("Events loaded: \(netEvents.count)")
                self.firstEvent = netEvents.first ?? Event.empty
                self.events = netEvents
                self.sort(netEvents)
            }
            .store(in: &subscribers)
    }

    private func sort(_ events: [Event]) {
        let now = Date()
        self.upcomingEvents = []
        self.pastEvents = []
        events.forEach { event in
            guard let startDate = event.startAt else { return }
            if startDate > now {
                self.upcomingEvents.append(event)
            } else {
                self.pastEvents.append(event)
            }
        }
        #if DEBUG
        let evt = testEvent()
        self.upcomingEvents.append(evt)
        #endif
    }

    func loadUpcomingEvents(for group: Group) {
        loadAllEvents(for: group)
            .map { events -> [Event] in
                let now = Date()
                return events.filter { event in
                    guard let startDate = event.startAt else {
                        return false
                    }
                    return startDate > now
                }
            }
            .receive(on: RunLoop.main)
            .sink { upcomingCompletion in
                switch upcomingCompletion {
                case .failure(let error):
                    self.logger.error("loadUpcomingEvents(for:) \(error.localizedDescription)")
                    self.netState = .failed(error)
                case .finished:
                    self.netState = .ready
                }
            } receiveValue: { upcomingEvts in
                self.upcomingEvents = upcomingEvts
            }
            .store(in: &subscribers)
    }
}

#if DEBUG
func testEvent() -> Event {
    let location = Location(latitude: Double(37.789004663475026),
                                   longitude: Double(-122.3970252426277))
    let imageURLString = "https://fastly.4sqi.net/img/general/1440x1920/"
        + "1813137_VPYk5iqnExTrW9lEMbbSy2WDS6P-lbOkpqsy5KE2sSI.jpg"
    let imgURL = URL(string: imageURLString)!
    let event = Event(id: UUID(),
                      groupID: UUID(),
                      name: "Test Event Here",
                      imageURL: imgURL,
                      startAt: Date(),
                      endAt: Date(),
                      venue: Venue(name: "Salesforce Park", location: location))
    return event
}
#endif
