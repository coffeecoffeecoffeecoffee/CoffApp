import SwiftUI
import WidgetKit

struct TheCoffeeWidgetEntryView: View {
    var entry: EventProvider.Entry

    // MARK: -
    var shadyPurple = Color("ShadyPurple")

    init(entries: EventProvider.Entry...) {
        self.entry = entries.first ?? EventEntry(.empty)
    }

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Spacer()
                Text(entry.event.statusText.uppercased())
                    .foregroundColor(.init(hue: 0.9,
                                           saturation: 0.7,
                                           brightness: 2.0))
                    .font(.caption2)
                Text(entry.event.venueName)
                    .font(.body)
                Text(entry.event.localizedStartTime(.short))
                    .font(.caption)
                    .foregroundColor(.init(hue: 0.9,
                                           saturation: 0.7,
                                           brightness: 2.0))
                if let startDate = entry.event.startAt {
                    Text(startDate, style: .timer)
                        .foregroundColor(.init(hue: 0.0,
                                               saturation: 0.5,
                                               brightness: 1.0))
                        .bold()
                }
            }
            Spacer()
        }
        .foregroundColor(.white)
        .containerBackground(for: .widget) {
            if let imageData = entry.imageData,
               let eventImage = try? Image(data: imageData) {
                eventImage
                    .centerCropped()
            } else {
                AsyncImagePhaseView(entry.event.imageURL)
            }
            LinearGradient(gradient:
                            Gradient(colors: [
                                .clear,
                                shadyPurple
                            ]),
                           startPoint: UnitPoint(x: 0.3, y: 0.0),
                           endPoint: UnitPoint(x: 0.0, y: 1.0)
            )
        }
    }
}

#if DEBUG
struct TheCoffeeWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TheCoffeeWidgetEntryView(entries: EventEntry(testEvent(true)))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
