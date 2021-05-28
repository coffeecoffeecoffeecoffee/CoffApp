import FetchImage
import SwiftUI

struct EventDetailView: View {
    @StateObject private var image = FetchImage()
    @State private var inFocus: Bool = false

    init(_ event: Event) {
        self.event = event
    }

    var event: Event
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            image.view?
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 240,
                       idealWidth: 512,
                       maxWidth: .infinity,
                       minHeight: 200,
                       idealHeight: 360,
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
            VStack(alignment: .leading) {
                Text(event.name)
                    .font(.title2)
                    .foregroundColor(.white)
                    .scaleEffect(inFocus ? 1.03 : 1)
                    .shadow(radius: inFocus ? 3 : 0)
                Text(event.venueName)
                    .font(.body)
                    .foregroundColor(.init(white: 0.8))
                Text(event.localizedStartTime)
                    .font(.body)
                    .bold()
                    .foregroundColor(.init(white: 0.8))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(minWidth: 240,
               idealWidth: 512,
               maxWidth: .infinity,
               minHeight: 200,
               idealHeight: 360,
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
        .shadow(radius: inFocus ? 10 : 0)
        .padding(10)
        .onAppear {
            if let url = event.imageURL {
                image.load(url)
            }
        }
        .focusable(true) { inFocus in
            withAnimation {
                self.inFocus = inFocus
            }
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let event = Event(id: UUID(),
                          groupID: UUID(),
                          name: "Test Event Here",
                          imageURL: URL(string: "https://fastly.4sqi.net/img/general/1440x1920/1813137_VPYk5iqnExTrW9lEMbbSy2WDS6P-lbOkpqsy5KE2sSI.jpg")!,
                          startAt: Date(),
                          endAt: Date(),
                          venue: Venue(name: "Mi Casa", location: nil))
        EventDetailView(event)
            .frame(width: 320, height: 240, alignment: .center)
    }
}
