import Combine
import Foundation
import Logging

final class NetworkService: ObservableObject {
    static var shared: NetworkService { .init() }
    @Published var groups = [InterestGroup]()
    @Published var events = [Event]() {
        didSet {
            upcomingEvents = events.upcoming()
            pastEvents = events.past()
        }
    }
    let eventsSubject = PassthroughSubject<[Event], Error>()
    @Published var firstEvent: Event = Event.loading
    @Published var upcomingEvents = [Event]()
    @Published var pastEvents = [Event]()
    @Published var netState = NetworkState.loading
    private var logger = Logger(label: Bundle.main.bundleIdentifier!
                                    .appending(".networkservice.log"))
    private var subscriptions = Set<AnyCancellable>()
    private var session = URLSession.shared
    private let decoder = JSONDecoder()

    private let groupURL = URL.appURL(with: "api", "groups")

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

    func cancelAll() {
        subscriptions.removeAll()
        firstEvent = Event.loading
        events = []
        self.netState = .ready
    }

    init() {
        decoder.dateDecodingStrategy = .iso8601
        loadGroups()
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
            .store(in: &subscriptions)
    }

    func groupForID(_ uid: UUID?) -> InterestGroup? {
        guard let uid else { return nil }
        return groups.first { group in
            group.id == uid
        }
    }
}

// MARK: - Events
extension NetworkService {

    private func downloadAllEvents(for group: InterestGroup) throws -> [Event] {
        let data = try Data(contentsOf: group.eventsURL)
        let events = try decoder.decode([Event].self, from: data)
        return events
    }

    public func downloadAllEvents(for groupIDs: Set<UUID>) async throws -> [Event] {
        guard !groupIDs.isEmpty else {
            self.events = []
            self.upcomingEvents = []
            self.pastEvents = []
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let allEventsSet = try await withThrowingTaskGroup(of: [Event].self,
                                                    returning: Set<Event>.self) { taskGroup in
            let evtGroups = groupIDs.map { uid in
                groupForID(uid) ?? InterestGroup(id: uid, name: uid.uuidString)
            }
            evtGroups.forEach { group in
                guard let url = group.eventsURL else { return }
                taskGroup.addTask {
                    do {
                        let (groupEventsData, _) = try await URLSession.shared.data(from: url)
                        let groupEvents = try decoder.decode([Event].self,
                                                             from: groupEventsData)
                        return groupEvents
                    } catch {
                        self.logger.error(.init(stringLiteral: error.localizedDescription))
                        return []
                    }
                }
            }

            var decodedEvents = Set<Event>()
            for try await groupEvents in taskGroup {
                decodedEvents.formUnion(groupEvents)
            }
            return decodedEvents
        }
        let sortedEvents = allEventsSet.sorted()
        handle(sortedEvents)
        return sortedEvents
    }

    func futureEvents(for group: InterestGroup) throws -> [Event] {
        self.events = try downloadAllEvents(for: group)
        let now = Date()
        let futureEvents = self.events.filter { event in
            guard let endDate = event.endAt else {
                return false
            }
            return endDate > now
        }
        return futureEvents
    }

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
                    self.handle([Event.error])
                case .finished:
                    self.logger.info("Events fetch complete")
                    self.netState = .ready
                }
            } receiveValue: { netEvents in
                self.logger.info("Events loaded: \(netEvents.count)")
                self.events = netEvents
            }
            .store(in: &subscriptions)
    }

    private func handle(_ events: [Event]) {
        let now = Date()
        self.upcomingEvents = []
        self.pastEvents = []
        var activeEvents = [Event]()
        events.forEach { event in
            guard let endDate = event.endAt else { return }
            if endDate > now {
                activeEvents.append(event)
            } else {
                self.pastEvents.append(event)
            }
        }
        #if TESTACTIVE
        let evt = testEvent()
        activeEvents.append(evt)
        #endif
        self.upcomingEvents = activeEvents.sorted(by: sortEvents)
        updateMostRecent()
    }

    // TODO: This is not the way
    private func updateMostRecent() {
        if !upcomingEvents.isEmpty {
            let nextEvent = upcomingEvents.sorted(orderedBy: .oldestFirst).first!
            nextEvent.saveAsMostRecent()
        } else if let lastEvent = pastEvents.first {
            lastEvent.saveAsMostRecent()
        } else {
            Event.empty.saveAsMostRecent()
        }
    }

    private func sortEvents(aVent: Event, bVent: Event) -> Bool {
        guard let aStart = aVent.startAt,
              let bStart = bVent.startAt else {
                  return true
              }
        return aStart < bStart
    }
}

#if DEBUG
func testEvent(_ isNearFuture: Bool = false) -> Event {
    let location = Location(latitude: Double(37.789004663475026),
                                   longitude: Double(-122.3970252426277))
    let imageURLString = "https://fastly.4sqi.net/img/general/1440x1920/"
        + "1813137_VPYk5iqnExTrW9lEMbbSy2WDS6P-lbOkpqsy5KE2sSI.jpg"
    let imgURL = URL(string: imageURLString)!
    let date = isNearFuture ? Date().advanced(by: 40_000) : Date().advanced(by: -20_000)
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
