import SwiftUI

struct EventListView: View {
    @EnvironmentObject var net: NetworkService
    var group: Group
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text(group.name)
                .font(.largeTitle)
            if net.netState == .loading {
                ProgressView(net.netState.description)
                Spacer()
            } else {
                List(net.events, id: \.id) { event in
                    Spacer()
                    EventDetailView(event: event)
                    Spacer()
                }
            }
        }
        .onAppear(perform: {
            net.loadEvents(for: group)
        })
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView(group: Group(id: UUID(uuidString: "28ef50f9-b909-4f03-9a69-a8218a8cbd99")!,
                                   name: "Test Group Name"))
            .environmentObject(NetworkService())
    }
}
