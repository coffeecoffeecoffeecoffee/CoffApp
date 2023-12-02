import WidgetKit
import SwiftUI
import Intents

@main
struct TheCoffeeWidget: Widget {
    let kind: String = "The Coffee"
    @Environment(\.widgetFamily) var family

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: EventProvider()) { entries in
            switch family {
            case .systemSmall:
                Text("Small")
            case .systemMedium:
                TheCoffeeWidgetEntryView(entries: entries)
            case .systemLarge:
                TheCoffeeWidgetEntryView(entries: entries)
            case .systemExtraLarge:
                TheCoffeeWidgetEntryView(entries: entries)
            case .accessoryCorner:
                Text("Corner")
            case .accessoryCircular:
                Text("Cir")
            case .accessoryRectangular:
                Text("AccRect")
            case .accessoryInline:
                Text("Inline")
            @unknown default:
                Text("Coffee!")
            }
        }
    }
}

#if DEBUG
struct TheCoffeeWidget_Previews: PreviewProvider {
    static var net = NetworkService()
    static var previews: some View {
//        TheCoffeeWidgetEntryView(entries: EventEntry(testEvent(true)))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))

//        TheCoffeeWidgetEntryView(entries: EventEntry(testEvent(true)))
//            .previewContext(WidgetPreviewContext(family: .systemMedium))

        TheCoffeeWidgetEntryView(entries: EventEntry(testEvent(true)))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
