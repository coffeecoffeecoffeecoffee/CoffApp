import SwiftUI

struct EventListView: View {
    @EnvironmentObject var net: NetworkService
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
                    LazyVStack(content: {
                        ForEach(net.events, id: \.self) { event in
                        EventDetailView(event)
                            .padding(.vertical, 10)
                            .frame(minWidth: .none,
                                   maxWidth: .infinity,
                                   minHeight: .none,
                                   maxHeight: .infinity,
                                   alignment: .center)
                            }
                        })
                    }
                }
            }
            .navigationTitle(group.name)
            .onAppear(perform: {
                withAnimation {
                    net.loadEvents(for: group)
                }
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
