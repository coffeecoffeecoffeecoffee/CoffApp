import SwiftUI

// watchOS
struct ContentView: View {
    @EnvironmentObject var networkService: NetworkService
    @StateObject private var groups = Groups()
    @SceneStorage("selectedGroup") var selectedGroup: String?
    var body: some View {
        ForEach(groups.groups) { group in
            List(networkService.groups, id: \.id) { group in
                NavigationLink(group.name,
                               destination: EventListWatchView(group: group)
                                .environmentObject(networkService),
                               tag: group.name,
                               selection: $selectedGroup)
            }
        }
        .onAppear(perform: {
            networkService.loadGroups()
        })
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NetworkService())
    }
}
#endif
