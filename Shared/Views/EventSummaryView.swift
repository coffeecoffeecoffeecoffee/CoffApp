// swiftlint:disable line_length
import SwiftUI

struct EventSummaryView: View {
    @State private var focusState = FocusState()
    let event: Event

    init(_ event: Event, group: InterestGroup? = nil) {
        self.event = event
    }

    var body: some View {
        TVFocusable(focusState) {
        HStack {
            ZStack {
                LinearGradient(gradient:
                    Gradient(colors: [
                        .init(.displayP3, red: 0.6, green: 0.3, blue: 0.1, opacity: 1.0),
                        .black
                    ]),
                               startPoint: UnitPoint(x: 0, y: 0),
                               endPoint: UnitPoint(x: 1, y: 1)
                )
                AsyncImagePhaseView(event.imageURL)
            }
            .frame(maxWidth: 64, maxHeight: 64)
            .cornerRadius(5)
            VStack(alignment: .leading) {
//                if let groupName = group?.name {
//                    Text(groupName)
//                        .foregroundColor(.secondary)
//                        .opacity(0.7)
//                        .font(.footnote)
//                }
                Text(event.name)
                    .bold()
                Text(event.localizedStartTime())
            }
        }
        .frame(minWidth: 64, maxWidth: .infinity, minHeight: 64, maxHeight: 64, alignment: .leading)
        .scaleEffect(focusState.inFocus ? 1.03 : 1)
        .shadow(radius: focusState.inFocus ? 3 : 0)
        .foregroundColor(.secondary)
        }
    }
}

#if DEBUG
struct EventSummaryView_Previews: PreviewProvider {
    static let imgURL = URL(string: "https://fastly.4sqi.net/img/general/1067x1897/4835820_mqBTxJRmEOlLRK-olPXrElaiIQlU1q5qSjExFIvHKtA.jpg")!
    static var testEvent = Event(id: UUID(),
                                 groupID: UUID(),
                                 name: "Test Event with a very long title right here",
                                 imageURL: imgURL,
                                 startAt: Date().addingTimeInterval(360),
                                 endAt: Date().addingTimeInterval(720),
                                 venue: Venue(name: "Equador", location: nil))
    static var previews: some View {
        EventSummaryView(testEvent)
    }
}
#endif
