import WidgetKit
import SwiftUI
import Intents

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
