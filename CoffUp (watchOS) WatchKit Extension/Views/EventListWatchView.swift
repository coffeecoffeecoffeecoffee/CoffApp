import FetchImage
import SwiftUI

// watchOS
struct EventListWatchView: View {
    @EnvironmentObject var networkService: NetworkService
    var group: Group

    // MARK: - Body
    var body: some View {
        ScrollView {
            ZStack(alignment: .bottom) {
                Image("Loading")
                    .data(networkService.firstEvent.imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 140)
                    .cornerRadius(10)
                    .clipped()
                VStack(alignment: .center) {
                    Text(networkService.firstEvent.venueName)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(networkService.firstEvent.localizedStartTime(.short))
                        .font(.footnote)
                }
                .font(.body)
                .padding(.all, 5)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.7).cornerRadius(10))
                .padding(.all, 5)
                .opacity(networkService.netState == .ready ? 1 : 0)
            }
            Button {
                networkService.firstEvent.venue?.getDirections()
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                    Text("Directions")
                }
            }
            .opacity(networkService.netState == .ready ? 1 : 0)
        }
        .onAppear {
            networkService.loadEvents(for: group)
            group.setSelectd()
        }
        .onDisappear {
            networkService.cancelAll()
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
