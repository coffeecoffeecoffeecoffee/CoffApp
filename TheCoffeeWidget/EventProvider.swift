import WidgetKit

struct EventProvider: IntentTimelineProvider {
    typealias Entry = EventEntry
    typealias Intent = ConfigurationIntent

    private var net = NetworkService()

    init() {
        net.selectedGroupUpcomingEvents()
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
        let entries: [EventEntry] = [
            EventEntry(mostRecentEvent,
                       configuration: configuration)
        ]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
