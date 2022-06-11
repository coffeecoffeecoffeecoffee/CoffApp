import Logging
import WidgetKit

class EventProvider: TimelineProvider {
    typealias Entry = EventEntry

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
        EventEntry(Event.empty)
    }

    func getSnapshot(in context: Context,
                     completion: @escaping (EventEntry) -> Void) {
        let entry = EventEntry(mostRecentEvent)
        completion(entry)
    }

    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<EventEntry>) -> Void) {
        guard let savedGroup = InterestGroup.loadSelected(),
               savedGroup.eventsURL != nil else {
                   logger.error(.init(stringLiteral: "No saved group"))
                   completion(Timeline(entries: [EventEntry(.error(text: "Coffee: Get Some!"))], policy: .atEnd))
                   return
        }
        let event = savedGroup.headlineEvent
        let entry = EventEntry(event,
                               date: event.startAt ?? Date().addingTimeInterval(-360))
        completion(Timeline(entries: [entry], policy: .atEnd))
    }
}
