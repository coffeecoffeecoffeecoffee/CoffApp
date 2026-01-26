import CoffeeKit
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
                if let urlString = event.imageURL,
                   let imageURL = URL(string: urlString) {
                    AsyncImagePhaseView(imageURL)
                }
                LinearGradient(gradient:
                                Gradient(colors: [
                                    .clear,
                                    Color("ShadyPurple")
                                        .opacity(0.7)
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
                        if let venue = event.venue {
                            Text(venue.name)
                                .font(.body)
                                .foregroundColor(.init(white: 0.8))
                            Text(event.localizedStartTime())
                                .font(.body)
                                .bold()
                                .foregroundColor(.init(white: 0.8))
                            if venue.location != nil
                                && RuntimeOS.current != .tvOS {
                                HStack(alignment: .firstTextBaseline, spacing: 20) {
                                    Button(action: {
                                        venue.getDirections()
                                    }, label: {
                                        HStack {
                                            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                                .padding(.vertical, 2)
                                            Text("Directions")
                                        }
                                    })
                                    .buttonStyle(RoundFilledButtonStyle(color: .blue))
                                    .transition(.scale(scale: 0.2, anchor: .bottomLeading))
                                    // TODO: Share Link
                                    /**
                                     #if !os(tvOS)
                                     ShareLink(item: event.shareURL(),
                                     subject: Text(event.name),
                                     message: Text("\(event.venueName) at \(event.localizedStartTime())"))
                                     #endif
                                     */
                                }
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            }
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
            .shadow(radius: focusState.inFocus ? 10 : 0)
        }
    }
}

#Preview {
    let location = Location(title: "Preview Location",
                            latitude: Double(37.789004663475026),
                            longitude: Double(-122.3970252426277)
    )
    let imgURL = URL(string: "https://coffeecoffee.world/default-coffee.webp")!
    let event = Event(id: UUID(),
                      name: "Test Event Here",
                      groupID: UUID(),
                      venue: Venue(
                        name: "Salesforce Park",
                        location: location
                      ),
                      imageURL: nil,
                      startAt: Date(),
                      endAt: Date()
    )
    EventDetailView(event)
}
