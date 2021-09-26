import Combine
import Foundation
import Logging

final class NetworkService: ObservableObject {
    @Published var selectedGroup: InterestGroup?
    @Published var groups = [InterestGroup]()
    @Published var events = [Event]()
    let eventsSubject = PassthroughSubject<[Event], Error>()
    @Published var firstEvent: Event = Event.loading
    @Published var upcomingEvents = [Event]()
    @Published var pastEvents = [Event]()
    @Published var netState = NetworkState.loading
    private var logger = Logger(label: Bundle.main.bundleIdentifier!
                                    .appending(".networkservice.log"))
    private var subscribers = Set<AnyCancellable>()
    private var session = URLSession.shared
    private var decoder = JSONDecoder()

    private let groupURL = URL.appURL(with: "api", "groups")

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
        firstEvent = Event.loading
        events = []
        self.netState = .ready
    }

    init() {
        decoder.dateDecodingStrategy = .iso8601
        observeSelectedGroup()
    }
}

// MARK: - Groups
extension NetworkService {
    func fetchNetworkGroups() -> AnyPublisher<[InterestGroup], Error> {
        session.dataTaskPublisher(for: groupURL)
            .retry(2)
            .map { $0.data }
            .decode(type: [InterestGroup].self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    func handle(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .failure(let error):
            self.logger.critical("Network Error \n\(error.localizedDescription)")
            self.netState = .failed(error)
        case .finished:
            self.logger.debug("Group Fetch Complete")
            self.netState = .ready
        }
    }

    func observeSelectedGroup() {
        UserDefaults.standard.publisher(for: \.selectedGroup)
            .debounce(for: 0.2, scheduler: RunLoop.current)
            .sink { [weak self] defaultsValue in
                guard let self = self else { return }
                self.selectedGroup = self.groups.first(where: { group in
                    group.name == defaultsValue
                })
            }
            .store(in: &subscribers)
    }

    func loadGroups() {
        netState = .loading
        logger.info("Loading all groups")
        fetchNetworkGroups()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else {
                    self?.logger.error("loadGroup() no self")
                    self?.netState = .failed(NetworkError.unknownError)
                    return
                }
                self.handle(completion)
            } receiveValue: { netGroups in
                self.logger.debug("fetched groups \n\(netGroups.count)")
                self.groups = netGroups
            }
            .store(in: &subscribers)
    }
}

// MARK: - Events
extension NetworkService {
    func loadAllEvents(for group: InterestGroup) -> AnyPublisher<[Event], Error> {
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

    func loadEvents(for group: InterestGroup) {
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
                if let firstEvent = netEvents.first {
                    self.firstEvent = firstEvent
                    firstEvent.saveAsMostRecent()
                } else {
                    self.firstEvent = Event.empty
                }
                self.events = netEvents
                self.sort(netEvents)
            }
            .store(in: &subscribers)
    }

    private func sort(_ events: [Event]) {
        let now = Date()
        self.upcomingEvents = []
        self.pastEvents = []
        var forthComingEvents = [Event]()
        events.forEach { event in
            guard let startDate = event.startAt else { return }
            if startDate > now {
                forthComingEvents.append(event)
            } else {
                self.pastEvents.append(event)
            }
        }
        #if DEBUG
        let evt = testEvent()
        forthComingEvents.append(evt)
        #endif
        self.upcomingEvents = forthComingEvents.sorted(by: sortEvents)
    }

    private func sortEvents(aVent: Event, bVent: Event) -> Bool {
        guard let aStart = aVent.startAt,
              let bStart = bVent.startAt else {
                  return true
              }
        return aStart < bStart
    }

    func loadUpcomingEvents(for group: InterestGroup) {
        loadAllEvents(for: group)
            .map { [weak self] events -> [Event] in
                guard let self = self else { return [] }
                let now = Date()
                let upcoming = events.filter { event in
                    guard let startDate = event.startAt else {
                        return false
                    }
                    return startDate > now
                }
                return upcoming.sorted(by: self.sortEvents)
            }
            .removeDuplicates()
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

    func selectedGroupUpcomingEvents() {
        guard let selectedGroup = selectedGroup else { return }
        loadUpcomingEvents(for: selectedGroup)
    }
}

#if DEBUG
func testEvent(_ isFuture: Bool = false) -> Event {
    let location = Location(latitude: Double(37.789004663475026),
                                   longitude: Double(-122.3970252426277))
    let imageURLString = "https://fastly.4sqi.net/img/general/1440x1920/"
        + "1813137_VPYk5iqnExTrW9lEMbbSy2WDS6P-lbOkpqsy5KE2sSI.jpg"
    let imgURL = URL(string: imageURLString)!
    let date = isFuture ? Date().advanced(by: 40_000) : Date().advanced(by: -20_000)
    let event = Event(id: UUID(),
                      groupID: UUID(),
                      name: "Test Event Here",
                      imageURL: imgURL,
                      startAt: date,
                      endAt: date.advanced(by: 720),
                      venue: Venue(name: "Salesforce Park", location: location))
    return event
}
#endif
