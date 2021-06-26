import WidgetKit
import SwiftUI
import Intents
import FetchImage

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

    private var net = NetworkService()

    init() {
        net.selectedGroupUpcomingEvents()
    }

    var mostRecentEvent: Event {
        net.firstEvent
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

    func isFuture(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return date > Date() ? true : false
    }

    func labelText(_ event: Event) -> String {
        guard let startDate = event.startAt else { return "" }
        if startDate > Date() {
            return "Next"
        }
        return "Previously"
    }

    var shadyPurple = Color(hue: 0.8,
                            saturation: 1.0,
                            brightness: 0.26)

    var body: some View {
        ZStack {
            Image("")
                .data(entry.event.imageURL)
                .centerCropped()
            LinearGradient(gradient:
                            Gradient(colors: [
                                        .clear,
                                        shadyPurple
                            ]),
                           startPoint: UnitPoint(x: 0.3, y: 0.0),
                           endPoint: UnitPoint(x: 0.0, y: 1.0)
            )
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    Text(labelText(entry.event).uppercased())
                        .foregroundColor(.init(hue: 0.6,
                                               saturation: 0.7,
                                               brightness: 3.0))
                        .font(.caption2)
                    Text(entry.event.venueName)
                        .font(.body)
                    Text(entry.event.localizedStartTime(.short))
                        .font(.caption)
                    if let startDate = entry.event.startAt,
                        isFuture(startDate) {
                        Text(startDate, style: .timer)
                            .foregroundColor(.yellow)
                            .bold()
                    }
                }
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 0, x: 1, y: 1)
                .shadow(color: shadyPurple, radius: 3, x: 0, y: 0)

                Spacer()
            }
            .padding(10)
        }
        .background(Color(hue: 0.1, saturation: 1.0, brightness: 1.0, opacity: 1.0))
    }
}

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}

struct PlaceholderView: View {
    var entry: EventProvider.Entry

    var body: some View {
        TheCoffeeWidgetEntryView(entry: entry)
    }
}

@main
struct TheCoffeeWidget: Widget {
    let kind: String = "The Coffee"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: ConfigurationIntent.self,
                            provider: EventProvider()) { entry in
            TheCoffeeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("The Coffee")
        .description("Keep track of your next coffee meetup.")
    }
}

#if DEBUG
struct TheCoffeeWidget_Previews: PreviewProvider {
    static var net = NetworkService()
    static var previews: some View {
        TheCoffeeWidgetEntryView(entry:
                                EventEntry(date: Date(),
                                           event: testEvent(true),
                                           configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        TheCoffeeWidgetEntryView(entry:
                                EventEntry(date: Date(),
                                           event: testEvent(true),
                                           configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        TheCoffeeWidgetEntryView(entry:
                                EventEntry(date: Date(),
                                           event: testEvent(true),
                                           configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
