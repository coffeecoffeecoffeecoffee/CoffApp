import SwiftUI

struct EventListView: View {
    @EnvironmentObject var net: NetworkService
    @EnvironmentObject var groups: Groups
    var group: Group

    var body: some View {
            VStack(alignment: .center) {
                if net.netState == .loading {
                    ProgressView(net.netState.description)
                        .padding(30)
                        .frame(minWidth: .none, maxWidth: .infinity, minHeight: 200, maxHeight: 320, alignment: .center)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 30) {
                            if net.upcomingEvents.count > 0 {
                                VStack {
                                    ForEach(net.upcomingEvents, id: \.self) { upcomingEvent in
                                        EventDetailView(upcomingEvent)
                                    }
                                }
                            } else {
                                HStack {
                                    Text("No upcoming events")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            if net.pastEvents.count > 0 {
                                Divider()
                                Text("Previously")
                                    .font(.title)
                                ForEach(net.pastEvents) { event in
                                    EventSummaryView(event)
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    .navigationTitle(group.name)
            }
        }
        .onAppear {
            group.setSelectd()
            net.loadEvents(for: group)
        }
    }
}

#if DEBUG
struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView(group: Group(id: UUID(uuidString: "28ef50f9-b909-4f03-9a69-a8218a8cbd99")!,
                                   name: "Test Group Name"))
            .environmentObject(NetworkService())
    }
}
#endif
