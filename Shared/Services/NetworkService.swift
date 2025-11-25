import Foundation
import Logging

@Observable
final class NetworkService {
    static let shared = NetworkService()
    
    private typealias JWTToken = String
    
    var groups = [InterestGroup]()
    var events = [Event]() {
        didSet {
            upcomingEvents = events.upcoming()
            pastEvents = events.past()
        }
    }
    
    var firstEvent: Event = Event.loading
    var upcomingEvents = [Event]()
    var pastEvents = [Event]()
    var netState = NetworkState.loading
    private var logger = Logger(label: Bundle.main.bundleIdentifier!
                                    .appending(".networkservice.log"))
    // private var subscriptions = Set<AnyCancellable>()
    private var session = URLSession.shared
    private var jwtToken: JWTToken? {
        get {
            UserDefaults.standard.string(forKey: "jwtToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "jwtToken")
        }
    }
    private let decoder = JSONDecoder()

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
        // subscriptions.removeAll()
        firstEvent = Event.loading
        events = []
        self.netState = .ready
    }

    init() {
        decoder.dateDecodingStrategy = .iso8601
    }
}

// MARK: -- User
extension NetworkService {
    
    private struct LoginResponse: Codable {
        let message: String
        let error: String?
        let token: JWTToken?
        
        enum CodingKeys: String, CodingKey {
            case message
            case error
            case token = "jwt-token"
        }
    }
    
    func signIn(_ email: String, password: String) async -> Result<String, Error> {
        let loginURL = URL.apiV2(with: "users", "login")
        var loginRequest = URLRequest(url: loginURL)
        loginRequest.httpMethod = "POST"
        
        // Configure HTTP Basic Authentication using email as username and password as password
        let credentials = "\(email):\(password)"
        if let credentialData = credentials.data(using: .utf8) {
            let base64Credentials = credentialData.base64EncodedString()
            loginRequest.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }
        loginRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (loginData, _) = try await session.data(for: loginRequest)
            let loginResponse = try decoder.decode(LoginResponse.self, from: loginData)
            guard let token = loginResponse.token else {
                throw CoffeeErrors.syncError(reason: loginResponse.message)
            }
            self.jwtToken = token
            try KeychainService.shared.saveString(token, for: .jwtToken)
            try KeychainService.shared.saveString(email, for: .email)
            try KeychainService.shared.saveString(password, for: .password)
            logger.info("Saved credentials to Keychain")
        } catch {
            return .failure(error)
        }
        return .success("Signed in")
    }
    
    func retrieveJWT(localizedReason: String = "Authenticate to access your account") throws -> String {
        try KeychainService.shared.loadString(for: .jwtToken, localizedReason: localizedReason)
    }

    func retrieveEmail(localizedReason: String = "Authenticate to access your account") throws -> String {
        try KeychainService.shared.loadString(for: .email, localizedReason: localizedReason)
    }

    func retrievePassword(localizedReason: String = "Authenticate to access your account") throws -> String {
        try KeychainService.shared.loadString(for: .password, localizedReason: localizedReason)
    }
}

// MARK: -- Venue
extension NetworkService {
    func loadVenues() async throws -> [Venue] {
        logger.info("Fetching venues from \(URL.venuesURL)")
        let (newVenues, _) = try await session.data(from: URL.venuesURL)
        let fetchedVenues = try JSONDecoder().decode([Venue].self, from: newVenues)
        logger.info("Fetched venues: \(fetchedVenues.count)")
        return fetchedVenues
    }
}

// MARK: -- Async InterestGroups
extension NetworkService {
    func loadGroups() async throws -> [InterestGroup] {
        logger.info("Fetching groups from \(URL.groupsURL)")
        let (newGroups, _) = try await session.data(from: URL.groupsURL)
        let fetchedGroups = try JSONDecoder().decode([InterestGroup].self, from: newGroups)
        logger.info("Groups fetch complete")
        return fetchedGroups
    }
}

// MARK: -- Async Events
extension NetworkService {
    public func loadEvents(for group: InterestGroup) async throws -> [Event] {
        let url = group.eventsURL
        netState = .loading
        logger.info("Fetching events from \(url)")
        let (newEvents, _) = try await session.data(from: url)
        let fetchedEvents = try decoder.decode([Event].self, from: newEvents)
        logger.info("Events fetch complete")
        netState = .ready
        return fetchedEvents
    }
    
    public func loadAllEvents(for groups: [InterestGroup]) async throws -> [InterestGroup: [Event]] {
        return try await withThrowingTaskGroup(of: (InterestGroup, [Event]).self) { taskGroup in
            for group in groups {
                taskGroup.addTask { [weak self] in
                    guard let self else { return (group, []) }
                    let events = try await self.loadEvents(for: group)
                    return (group, events)
                }
            }

            var allEvents = [InterestGroup: [Event]]()
            for try await (group, events) in taskGroup {
                allEvents[group] = events
            }
            return allEvents
        }
    }
    
    public func downloadAllEvents(for groupIDs: Set<UUID>) async throws -> [Event] {
        netState = .loading
        logger.info("Downloading all events")
        guard !groupIDs.isEmpty else {
            self.events = []
            self.upcomingEvents = []
            self.pastEvents = []
            return []
        }
        let allEventsSet = try await withThrowingTaskGroup(of: [Event].self,
                                                    returning: Set<Event>.self) { taskGroup in
            let evtGroups = groupIDs.map { uid in
                InterestGroup(id: uid, name: uid.uuidString, imageURL: nil)
            }
            evtGroups.forEach { group in
                taskGroup.addTask { [weak self] in
                    guard let self else { return [] }
                    logger.info("Fetching events for \(group.name)")
                    do {
                        let groupEventsURL = group.eventsURL
                        let (groupEventsData, _) = try await session.data(from: groupEventsURL)
                        let groupEvents = try decoder.decode([Event].self,
                                                             from: groupEventsData)
                        logger.info("Fetched events for: \(group.name)")
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
        netState = .ready
        logger.info("Done downloading all events")
        return allEventsSet.sorted()
    }
}


/**
// MARK: - DEPRECATED Combine Groups
extension NetworkService {
    @available(*, deprecated, renamed: "loadAllEvents(for:)", message: "Combine is deprecated, please use async/await instead")
    func fetchNetworkGroups() -> AnyPublisher<[InterestGroup], Error> {
        session.dataTaskPublisher(for: URL.groupsURL)
            .debounce(for: .seconds(5), scheduler: RunLoop.current)
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

    @available(*, deprecated, renamed: "loadAllEvents(for:)", message: "Combine is deprecated, please use async/await instead")
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
*/

// MARK: - DEPRECATED Combine Events
/**
 extension NetworkService {

//    private func downloadAllEvents(for group: InterestGroup) async throws -> [Event] {
//        let (data, _) = try await session.data(from: group.eventsURL)
//        let events = try decoder.decode([Event].self, from: data)
//        return events
//    }

    

    @available(*, deprecated, renamed: "loadAllEvents(for:)", message: "This will be removed soon")
    func futureEvents(for group: InterestGroup) async throws -> [Event] {
        self.events = try await loadEvents(for: group)
        let now = Date()
        let futureEvents = self.events.filter { event in
            guard let endDate = event.endAt else {
                return false
            }
            return endDate > now
        }
        return futureEvents
    }

    @available(*, deprecated, renamed: "loadAllEvents(for:)", message: "Combine is deprecated, use async/await instead")
    func loadAllEvents(for group: InterestGroup) -> AnyPublisher<[Event], Error> {
        let url = group.eventsURL
        netState = .loading
        return session.dataTaskPublisher(for: url)
            .retry(5)
            .map {
                $0.data
            }
            .decode(type: [Event].self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    @available(*, deprecated, renamed: "loadEvents(for:)", message: "Combine is deprecated, use async/await instead")
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

    @available(*, deprecated, renamed: "handle(_:)", message: "Don’t do this")
    private func handle(_ events: [Event]) {
        let now = Date()
        self.upcomingEvents = []
        self.pastEvents = []
        var activeEvents = [Event]()
        events.forEach { event in
            guard let endDate = event.endAt else {
                return
            }
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
    @available(*, deprecated, renamed: "filter", message: "Don’t do this")
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
*/

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
                      venue: Venue(name: "Salesforce Park",
                                   location: location),
                      venueID: nil,
                )
    return event
}
#endif

