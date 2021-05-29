import SwiftUI

// watchOS
struct EventListWatchView: View {
    @EnvironmentObject var networkService: NetworkService
    var group: Group
    
    // MARK: - Body
    var body: some View {
        List(networkService.events) { event in
            Text(event.name)
                .font(.body)
        }
        .onAppear(perform: {
            networkService.loadEvents(for: group)
        })
    }
}

// MARK: -  Previews
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
