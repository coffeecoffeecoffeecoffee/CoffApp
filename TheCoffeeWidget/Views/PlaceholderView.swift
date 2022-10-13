import SwiftUI
import WidgetKit

struct PlaceholderView: View {
    var entry: EventProvider.Entry

    var body: some View {
        TheCoffeeWidgetEntryView(entries: entry)
    }
}
