import FetchImage
import SwiftUI

struct EventDetailView: View {
    @StateObject private var image = FetchImage()
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
            VStack(alignment: .leading) {
                Text(event.name)
                    .font(.headline)
                Text(event.venue?.name ?? "Mystery Location")
                    .font(.subheadline)
                Text(event.localizedStartTime)
                    .bold()
            }
            .foregroundColor(Color.black)
            .frame(minWidth: .none, maxWidth: 360)
            .padding(10)
            .cornerRadius(5)
            .background(Color.white.opacity(0.85))
            .rotationEffect(.init(degrees: Double.random(in: -8...8)))
        }
        .frame(minWidth: 240,
               idealWidth: 512,
               maxWidth: .infinity,
               minHeight: 200,
               idealHeight: 360,
               maxHeight: .infinity,
               alignment: .center)
        .background(Color.black)
        .mask(Circle())
        .background(Circle().inset(by: -10).foregroundColor(.white))
//        .shadow(radius: 20)
        .transformEffect(.init(translationX: .random(in: -30...30), y: .random(in: 0...150)))
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
        EventDetailView(event: event)
            .frame(width: 320, height: 240, alignment: .center)
    }
}
