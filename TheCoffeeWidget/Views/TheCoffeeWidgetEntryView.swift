import SwiftUI
import WidgetKit

struct TheCoffeeWidgetEntryView: View {
    var entry: EventProvider.Entry

    // MARK: -
    // TOOD: Move to view model
    func relativelyFormatted(_ date: Date) -> String {
        let relativeDateFormatter = RelativeDateTimeFormatter()
        relativeDateFormatter.unitsStyle = .full
        let relativeDateDescription = relativeDateFormatter.localizedString(for: date, relativeTo: .now)
        return relativeDateDescription.localizedCapitalized
    }

    func isNearFuture(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        // TODO: Better handling here with time zones and DateComponent and whatnot
        let secondsIn24Hours = 86_400
        let recencyRangeInSeconds = (-secondsIn24Hours * 2)...0
        let secondsFromNow = Int(date.timeIntervalSinceNow) // which is negative if the future
        if recencyRangeInSeconds.contains(secondsFromNow) {
            return true
        }
        return false
    }

    // MARK: -

    var shadyPurple = Color("ShadyPurple")

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
                        if isNearFuture(startDate) {
                            Text(startDate, style: .timer)
                                .foregroundColor(.yellow)
                                .bold()
                        } else {
                            Text(relativelyFormatted(startDate))
                                .foregroundColor(.init(hue: 0.6,
                                                       saturation: 0.7,
                                                       brightness: 3.0))
                                .font(.caption2)
                        }
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
        TheCoffeeWidgetEntryView(entry: EventEntry(testEvent(true)))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
