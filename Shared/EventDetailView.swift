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
                .clipped()
            VStack(alignment: .center) {
                Text(event.name)
                    .font(.largeTitle)
                Text(event.venue?.name ?? "Mystery Location")
                    .font(.headline)
                Text(event.localizedStartTime)
                    .font(.subheadline)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.accentColor.cornerRadius(20).opacity(0.7))
        }
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
                          imageURL: nil,
                          startAt: Date(),
                          endAt: Date(),
                          venue: nil)
        EventDetailView(event: event)
    }
}
