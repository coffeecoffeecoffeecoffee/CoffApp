import Logging
import WidgetKit

class EventProvider: TimelineProvider {
    typealias Entry = EventEntry

    private var profile = UserProfile()
    private let decoder: JSONDecoder
    private let logger = Logger(label: "science.pixel.espresso.eventprovider")

    init() {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    var mostRecentEvent: Event {
        if let savedEvent = Event.loadMostRecent() {
            return savedEvent
        }
        return Event.empty
    }

    func placeholder(in context: Context) -> EventEntry {
        EventEntry(Event.empty)
    }

    func getSnapshot(in context: Context,
                     completion: @escaping (EventEntry) -> Void) {
        let entry = EventEntry(mostRecentEvent)
        completion(entry)
    }

    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<EventEntry>) -> Void) {
        Task {
            do {
                try await profile.sync()
            } catch {
                logger.error(.init(stringLiteral: error.localizedDescription))
            }
            let event = profile.upcomingEvents.first ?? .empty
            let entry = EventEntry(event,
                                   date: event.startAt ?? Date().addingTimeInterval(-360))
            completion(Timeline(entries: [entry], policy: .atEnd))
        }
    }
}
