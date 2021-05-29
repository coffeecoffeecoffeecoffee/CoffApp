import SwiftUI

// watchOS
struct ContentView: View {
    @EnvironmentObject var networkService: NetworkService
    var body: some View {
        ForEach(networkService.groups) { group in
            List(networkService.groups, id: \.id) { group in
                NavigationLink(group.name, destination: EventListWatchView(group: group)
                                .environmentObject(networkService))
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
