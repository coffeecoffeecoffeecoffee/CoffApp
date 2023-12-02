import SwiftUI
import WidgetKit

struct PlaceholderView: View {
    @Environment(\.widgetFamily) private var family
    var entry: EventProvider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            Text("Small")
        case .systemMedium:
            Text("Medium")
        case .systemLarge:
            TheCoffeeWidgetEntryView(entries: entry)
        case .systemExtraLarge:
            TheCoffeeWidgetEntryView(entries: entry)
        case .accessoryCorner:
            Text("Corner")
        case .accessoryCircular:
            Text("Circle")
        case .accessoryRectangular:
            Text("AccesRect")
        case .accessoryInline:
            Text("Inline")
        @unknown default:
            Text("Coffee!")
        }
    }
}
