import WidgetKit
import SwiftUI
import Intents

@main
struct TheCoffeeWidget: Widget {
    let kind: String = "The Coffee"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: EventProvider()) { entries in
            TheCoffeeWidgetEntryView(entries: entries)
        }
        .configurationDisplayName("The Coffee")
        .description("Keep track of your next coffee meetup.")
    }
}

#if DEBUG
struct TheCoffeeWidget_Previews: PreviewProvider {
    static var net = NetworkService()
    static var previews: some View {
        TheCoffeeWidgetEntryView(entries: EventEntry(testEvent(true)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        TheCoffeeWidgetEntryView(entries: EventEntry(testEvent(true)))
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        TheCoffeeWidgetEntryView(entries: EventEntry(testEvent(true)))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
