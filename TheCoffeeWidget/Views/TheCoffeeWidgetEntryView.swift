import SwiftUI
import WidgetKit

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
            if let imageData = entry.imageData,
                let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
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

#if DEBUG
struct TheCoffeeWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TheCoffeeWidgetEntryView(entry: EventEntry(testEvent(true),
                                                   configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
