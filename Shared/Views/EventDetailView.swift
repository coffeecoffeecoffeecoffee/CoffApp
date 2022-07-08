// swiftlint:disable line_length
import SwiftUI

struct EventDetailView: View {
    @StateObject private var focusState = FocusState()

    init(_ event: Event) {
        self.event = event
    }

    var event: Event

    var body: some View {
        TVFocusable(focusState) {
            ZStack(alignment: .bottomLeading) {
                AsyncImagePhaseView(event.imageURL)
                LinearGradient(gradient:
                                Gradient(colors: [
                                    .clear,
                                    Color("ShadyPurple")
                                ]),
                               startPoint: UnitPoint(x: 0.5, y: 0.45),
                               endPoint: UnitPoint(x: 0.48, y: 0.75))
                .blendMode(.hardLight)
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text(event.name)
                            .font(.title2)
                            .foregroundColor(.white)
                            .scaleEffect(focusState.inFocus ? 1.03 : 1)
                            .shadow(radius: focusState.inFocus ? 3 : 0)
                        Text(event.venueName)
                            .font(.body)
                            .foregroundColor(.init(white: 0.8))
                        Text(event.localizedStartTime())
                            .font(.body)
                            .bold()
                            .foregroundColor(.init(white: 0.8))
                        if event.venue?.location != nil
                            && RuntimeOS.current != .tvOS {
                            HStack(alignment: .firstTextBaseline, spacing: 20) {
                                Button(action: {
                                    event.venue?.getDirections()
                                }, label: {
                                    HStack {
                                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                            .padding(.vertical, 2)
                                        Text("Directions")
                                    }
                                })
                                .buttonStyle(RoundFilledButtonStyle(color: .blue))
                                .transition(.scale(scale: 0.2, anchor: .bottomLeading))
                                ShareLink(item: event.shareURL(),
                                          subject: Text(event.name),
                                          message: Text("\(event.venueName) at \(event.localizedStartTime())"))
                                #if os(macOS)
                                .buttonStyle(.link)
                                #endif
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        }

                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(
                LinearGradient(gradient:
                                Gradient(colors: [
                                    .init(.displayP3, red: 0.6, green: 0.3, blue: 0.1, opacity: 1.0),
                                    .black
                                ]),
                               startPoint: UnitPoint(x: 0, y: 0),
                               endPoint: UnitPoint(x: 1, y: 1)
                              )
            )
            .cornerRadius(10)
            .shadow(radius: focusState.inFocus ? 10 : 0)
            .padding(.vertical, 10)
        }
    }
}

#if DEBUG
struct EventDetailView_Previews: PreviewProvider {
    static let location = Location(latitude: Double(37.789004663475026),
                                   longitude: Double(-122.3970252426277))
    static let imgURL = URL(string: "https://fastly.4sqi.net/img/general/1440x1920/1813137_VPYk5iqnExTrW9lEMbbSy2WDS6P-lbOkpqsy5KE2sSI.jpg")!
    static var previews: some View {
        let event = Event(id: UUID(),
                          groupID: UUID(),
                          name: "Test Event Here",
                          imageURL: imgURL,
                          startAt: Date(),
                          endAt: Date(),
                          venue: Venue(name: "Salesforce Park", location: location))
        EventDetailView(event)
            .frame(width: 320.0, height: 240.0, alignment: .center)
    }
}
#endif
