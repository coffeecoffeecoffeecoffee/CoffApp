import Foundation
import Logging

@Observable
final class NetworkService: NetworkServicing {
    static let shared = NetworkService()
    
    private typealias JWTToken = String
    
    var groups = [InterestGroup]()
    var events = [Event]() {
        didSet {
            upcomingEvents = events.upcoming()
            pastEvents = events.past()
        }
    }
    
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
    private let encoder = JSONEncoder()

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
        events = []
        self.netState = .ready
    }

    init() {
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }
    
    public func jwtHeader() throws -> String {
        guard let token = jwtToken else {
            let failureMessage = "Need to be signed in"
            self.logger.critical("\(failureMessage)")
            throw CoffeeErrors.invalid(reason: failureMessage)
        }
        return "Bearer \(token)"
    }
}

// MARK: -- User
extension NetworkService {
    
    private struct LoginSuccessResponse: Codable {
        let message: String
        let token: JWTToken
        
        enum CodingKeys: String, CodingKey {
            case message
            case token = "jwt-token"
        }
    }
    
    private struct LoginFailureResponse: Codable {
        let reason: String
        let error: Bool
    }
    
    private func handleServerError(_ data: Data) -> CoffeeErrors {
        let loginResponse = try? decoder.decode(LoginFailureResponse.self, from: data)
        return CoffeeErrors.syncError(reason: loginResponse?.reason ?? "Server error")
    }
    
    func signIn(_ email: String, password: String) async -> Result<String, CoffeeErrors> {
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
            guard let loginResponse = try? decoder.decode(LoginSuccessResponse.self, from: loginData) else {
                return .failure(handleServerError(loginData))
            }
            let token = loginResponse.token
            self.jwtToken = token
            do {
                try KeychainService.shared.saveString(token, for: .jwtToken)
                try KeychainService.shared.saveString(email, for: .email)
                try KeychainService.shared.saveString(password, for: .password)
            } catch {
                logger.critical("\(error.localizedDescription)")
                return .failure(CoffeeErrors.syncError(reason: error.localizedDescription))
            }
            logger.info("Saved credentials to Keychain")
        } catch {
            let undefinedError = CoffeeErrors.syncError(reason: error.localizedDescription)
            return .failure(undefinedError)
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
                    do {
                        let events = try await self.loadEvents(for: group)
                        return (group, events)
                    } catch {
                        logger.error("Failed to load events for \(group): \(String(describing: error))")
                        return (group, [])
                    }
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
            let newDecoder = JSONDecoder()
            newDecoder.dateDecodingStrategy = .iso8601
            evtGroups.forEach { group in
                taskGroup.addTask { [weak self] in
                    guard let self else { return [] }
                    logger.info("Fetching events for \(group.name)")
                    do {
                        let groupEventsURL = group.eventsURL
                        let (groupEventsData, _) = try await session.data(from: groupEventsURL)
                        let groupEvents = try newDecoder.decode([Event].self,
                                                             from: groupEventsData)
                        logger.info("Fetched events for: \(group.name): \(groupEvents.count)")
                        return groupEvents
                    } catch {
                        #if DEBUG
                        print(String(describing: error))
                        #endif
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
    
    public func createEvent(_ event: Event) async -> Result<Event, CoffeeErrors> {
        guard let jwtHeader = try? jwtHeader() else {
            return .failure(CoffeeErrors.signInRequired)
        }
        netState = .loading
        logger.info("Creating event: \(event.name)")
        do {
            let eventData = try encoder.encode(event)
            var createEventRequest = URLRequest(url: URL.apiV2(with: "events"))
            createEventRequest.httpMethod = "POST"
            createEventRequest.setValue(jwtHeader, forHTTPHeaderField: "Authorization")
            createEventRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            createEventRequest.httpBody = eventData
            let (result, response) = try await session.data(for: createEventRequest)
            if let loginFailureResponse = try? decoder.decode(LoginFailureResponse.self, from: result) {
                self.jwtToken = nil
                if loginFailureResponse.reason.contains("exp claim verification failed: expired") {
                    // Fetch the credentials from the KeychainService and attempt a login
                }
                return .failure(.syncError(reason: loginFailureResponse.reason))
            }
            if let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) == false {
                return .failure(CoffeeErrors.syncError(reason: result.debugDescription))
            }
            // Server returns Int-based timestamps
            let serverEvent = try JSONDecoder().decode(Event.self, from: result)
            return .success(serverEvent)
        } catch {
            self.logger.critical("\(String(describing: error))")
            self.netState = .failed(error)
            let errorThing = CoffeeErrors.syncError(reason: error.localizedDescription)
            return .failure(errorThing)
        }
    }
}

#if DEBUG
func testEvent(_ isNearFuture: Bool = false) -> Event {
    let location = Location(title: "Test Location", latitude: Double(37.789004663475026),
                                   longitude: Double(-122.3970252426277))
    let imageURLString = "https://fastly.4sqi.net/img/general/1440x1920/"
        + "1813137_VPYk5iqnExTrW9lEMbbSy2WDS6P-lbOkpqsy5KE2sSI.jpg"
    let imgURL = URL(string: imageURLString)!
    let date = isNearFuture ? Date().advanced(by: 40_000) : Date().advanced(by: -20_000)
    let event = Event(id: UUID(),
                      name: "Test Event Here", groupID: UUID(),
                      venue: Venue(name: "Salesforce Park",
                                   location: location), imageURL: imgURL,
                      startAt: date,
                      endAt: date.advanced(by: 720),
                )
    return event
}
#endif


