import WidgetKit

struct EventProvider: IntentTimelineProvider {
    typealias Entry = EventEntry
    typealias Intent = ConfigurationIntent

    private var net = NetworkService()

    init() {
        net.selectedGroupUpcomingEvents()
    }

    var mostRecentEvent: Event {
        let groupName = Group.loadSelected() ?? "Wut?"
        let event = Event(id: UUID(),
                          groupID: UUID(),
                          name: groupName,
                          imageURL: nil,
                          startAt: Date().advanced(by: 6000),
                          endAt: Date().advanced(by: 8000),
                          venue: Venue(name: groupName,
                                       location: nil))
        return event
    }

    func placeholder(in context: Context) -> EventEntry {
        EventEntry(date: Date(),
                   event: Event.empty,
                   configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (EventEntry) -> Void) {
        let entry = EventEntry(date: Date(),
                               event: mostRecentEvent,
                               configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<EventEntry>) -> Void) {
        let entries: [EventEntry] = [
            EventEntry(date: Date(),
                       event: mostRecentEvent,
                       configuration: configuration)
        ]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
