import Combine

protocol DataSource {
    var selectedGroup: InterestGroup? { get }
    var groups: [InterestGroup] { get }
    var events: [Event] { get }
    var eventsSubject: PassthroughSubject<[Event], Error> { get }
    var firstEvent: Event { get }
    var upcomingEvents: [Event] { get }
    var pastEvents: [Event] { get }

    func loadGroups()
    func futureEvents(for group: InterestGroup) async throws -> [Event]
    func loadAllEvents(for group: InterestGroup) -> AnyPublisher<[Event], Error>
}
