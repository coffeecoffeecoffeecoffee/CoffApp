import FetchImage
import SwiftUI

// watchOS
struct EventListWatchView: View {
    @EnvironmentObject var networkService: NetworkService
    var group: Group

    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading) {
                    Image("Loading")
                        .data(networkService.firstEvent.imageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: geo.size.width, maxHeight: 70)
                        .cornerRadius(10)
                        .clipped()
                    VStack(alignment: .leading) {
                        Text(networkService.firstEvent.venueName)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Text(networkService.firstEvent.localizedStartTime(.short))
                            .font(.footnote)
                        Button {
                            networkService.firstEvent.venue?.getDirections()
                        } label: {
                            Text("Directions")
                        }

                    }
                    .font(.body)
                    .padding(.all, 10)
                    .background(Color.black.opacity(0.7).cornerRadius(10))
                }
                .frame(maxWidth: geo.size.width, maxHeight: geo.size.width)
            }
        }
        .onAppear {
            networkService.loadEvents(for: group)
        }
    }
}

// MARK: - Previews
#if DEBUG
struct EventListWatchView_Previews: PreviewProvider {
    static let testGroup = Group(id: UUID(uuidString: "28ef50f9-b909-4f03-9a69-a8218a8cbd99")!,
                          name: "Test Group")
    static var previews: some View {
        EventListWatchView(group: testGroup)
            .environmentObject(NetworkService())
    }
}
#endif
