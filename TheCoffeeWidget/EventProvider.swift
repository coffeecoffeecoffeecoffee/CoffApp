import Logging
import WidgetKit

class EventProvider: IntentTimelineProvider {
    typealias Entry = EventEntry
    typealias Intent = ConfigurationIntent

    private var net = NetworkService()
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
        EventEntry(Event.empty,
                   configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (EventEntry) -> Void) {
        let entry = EventEntry(mostRecentEvent,
                               configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<EventEntry>) -> Void) {
        guard let savedGroup = InterestGroup.loadSelected(),
               savedGroup.eventsURL != nil else {
                   logger.error(.init(stringLiteral: "No saved group"))
                   completion(Timeline(entries: [EventEntry(.error(text: "Coffee: Get Some!"))], policy: .atEnd))
                   return
        }
        let event = savedGroup.headlineEvent
        let entry = EventEntry(event,
                               date: event.startAt ?? Date().addingTimeInterval(-360),
                               configuration: configuration)
        completion(Timeline(entries: [entry], policy: .atEnd))
    }
}
