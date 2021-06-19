import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct EventProvider: IntentTimelineProvider {
    typealias Entry = EventEntry
    typealias Intent = ConfigurationIntent

    func placeholder(in context: Context) -> EventEntry {
        EventEntry(date: Date(), event: Event.empty, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (EventEntry) -> Void) {
        let entry = EventEntry(date: Date(), event: Event.loading, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<EventEntry>) -> Void) {
        var entries: [EventEntry] = []
        let someEvent = Event(id: UUID(),
                              groupID: UUID(),
                              name: "Timeline Event",
                              imageURL: nil,
                              startAt: Date().advanced(by: 60_000),
                              endAt: Date().advanced(by: 66_000),
                              venue: Venue(name: "Some Venue", location: nil))
        entries.append(EventEntry(date: Date().advanced(by: 60_000),
                               event: someEvent,
                               configuration: configuration))
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct EventEntry: TimelineEntry {
    var date: Date
    let event: Event
    let configuration: ConfigurationIntent
}

struct TheCoffeeWidgetEntryView: View {
    var entry: EventProvider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text(entry.event.name)
                .font(.caption)
            Text(entry.event.venueName)
                .font(.body)
            Text(entry.event.localizedStartTime(.short))
                .font(.caption)
            Text(entry.date.advanced(by: 7_000), style: .timer)
        }
        .padding()
    }
}

struct PlaceholderView: View {
    var entry: EventProvider.Entry

    var body: some View {
        Text("Nope")
    }
}

@main
struct TheCoffeeWidget: Widget {
    let kind: String = "The Coffee"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: EventProvider()) { entry in
            TheCoffeeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("The Coffee")
        .description("Keep track of your next coffee meetup.")
    }
}

#if DEBUG
struct TheCoffeeWidget_Previews: PreviewProvider {
    static var previews: some View {
        TheCoffeeWidgetEntryView(entry:
                                    EventEntry(date: Date(), event: Event.error, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
#endif
