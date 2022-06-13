import SwiftUI

// watchOS
struct ContentView: View {
    @StateObject var profile = UserProfile()
    var body: some View {
//        ForEach(groups.groups) { group in
//            List(networkService.groups, id: \.id) { group in
//                NavigationLink(group.name,
//                               destination: EventListWatchView(group: group)
//                                .environmentObject(networkService),
//                               tag: group.name,
//                               selection: $selectedGroup)
//            }
//        }
        LazyVStack {
            EventListWatchView(headline: "Upcoming", events: profile.upcomingEvents)
            EventListWatchView(headline: "Previously", events: profile.pastEvents)
        }
        .task {
            do {
                try await profile.sync()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
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
