import SwiftUI

// watchOS
struct EventListWatchView: View {
    var headline: String
    var events: [Event]

    // MARK: - Body
    var body: some View {
        Text(headline)
        ScrollView {
            List(events) { event in
                ZStack(alignment: .bottom) {
                    AsyncImage(url: event.imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxHeight: 140)
                                .cornerRadius(10)
                                .clipped()
                        default:
                            EmptyView()
                        }
                    }
                    VStack(alignment: .center) {
                        Text(event.name)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Text(event.localizedStartTime(.short))
                            .font(.footnote)
                    }
                    .font(.body)
                    .padding(.all, 5)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.7).cornerRadius(10))
                    .padding(.all, 5)
                }
                Button {
                    event.venue?.getDirections()
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        Text("Directions")
                    }
                }
            }
        }
    }
}

// MARK: - Previews
//#if DEBUG
//struct EventListWatchView_Previews: PreviewProvider {
//    static let testGroup = InterestGroup(id: UUID(uuidString: "28ef50f9-b909-4f03-9a69-a8218a8cbd99")!,
//                          name: "Test Group")
//    static var previews: some View {
//        EventListWatchView(group: testGroup)
//            .environmentObject(NetworkService())
//    }
//}
//#endif
