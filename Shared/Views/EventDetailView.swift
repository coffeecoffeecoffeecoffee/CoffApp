import FetchImage
import SwiftUI

struct EventDetailView: View {
    @StateObject private var image = FetchImage()

    init(_ event: Event) {
        self.event = event
    }

    var event: Event
    var body: some View {
        ZStack(alignment: .center) {
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
            VStack(alignment: .leading) {
                Text(event.name)
                    .font(.headline)
                Text(event.venueName)
                    .font(.subheadline)
                Text(event.localizedStartTime)
                    .bold()
            }
            .foregroundColor(Color.black)
            .frame(minWidth: .none, maxWidth: .infinity)
            .padding(10)
            .cornerRadius(5)
            .background(Color.white.opacity(0.85))
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
        .onAppear {
            if let url = event.imageURL {
                image.load(url)
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
