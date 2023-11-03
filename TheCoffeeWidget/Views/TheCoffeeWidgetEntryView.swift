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
        ZStack {
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
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    Text(entry.event.statusText.uppercased())
                        .foregroundColor(.init(hue: 0.6,
                                               saturation: 0.7,
                                               brightness: 3.0))
                        .font(.caption2)
                    Text(entry.event.venueName)
                        .font(.body)
                    Text(entry.event.localizedStartTime(.short))
                        .font(.caption)
                    if let startDate = entry.event.startAt {
                        Text(startDate, style: .timer)
                            .foregroundColor(.init(hue: 0.6,
                                                   saturation: 0.7,
                                                   brightness: 3.0))
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

#if DEBUG
struct TheCoffeeWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TheCoffeeWidgetEntryView(entries: EventEntry(testEvent(true)))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
