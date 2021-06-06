// swiftlint:disable line_length
import FetchImage
import SwiftUI

struct EventDetailView: View {
    @StateObject private var image = FetchImage()
    @StateObject private var focusState = FocusState()

    init(_ event: Event) {
        self.event = event
    }

    var event: Event
    var body: some View {
        TVFocusable(focusState) {
        ZStack(alignment: .bottomLeading) {
            image.view?
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 240,
                       idealWidth: 512,
                       maxWidth: .infinity,
                       minHeight: focusState.inFocus ? 640 : 200,
                       idealHeight: 640,
                       maxHeight: .infinity,
                       alignment: .center)
                .clipped()
            LinearGradient(gradient:
                            Gradient(colors: [
                                .clear,
                                .init(.displayP3, red: 0.0, green: 0.0, blue: 0.0, opacity: 0.7)
                            ]),
                           startPoint: UnitPoint(x: 0.5, y: 0.55),
                           endPoint: UnitPoint(x: 0.5, y: 0.75))
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
                    if focusState.inFocus
                        && event.venue?.location != nil
                        && RuntimeOS.current != .tvOS {
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
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                if RuntimeOS.current != .tvOS {
                    Spacer()
                    Text(focusState.inFocus ? Image(systemName: "rectangle.compress.vertical") : Image(systemName: "rectangle.expand.vertical"))
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Circle().foregroundColor(.blue))
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                }
            }
            .onLongPressGesture(minimumDuration: 0.02) {
                withAnimation {
                    focusState.toggleFocus()
                }
            }
        }
        .frame(minWidth: 240,
               idealWidth: 512,
               maxWidth: .infinity,
               minHeight: focusState.inFocus ? 640 : 200,
               idealHeight: focusState.inFocus ? 640 : 360,
               maxHeight: .infinity,
               alignment: .center)
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
        .padding(10)
        }
        .onAppear {
            if let url = event.imageURL {
                image.load(url)
            }
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
