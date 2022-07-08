import SwiftUI

// watchOS
struct ContentView: View {
    @StateObject var profile = UserProfile()
    var body: some View {
        LazyVStack {
            EventListWatchView(headline: "Upcoming", events: profile.upcomingEvents)
            EventListWatchView(headline: "Previously", events: profile.pastEvents)
        }
        .task {
            do {
                try await profile.sync()
            } catch {
                // TODO: Proper error handling
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
