import Logging
import SwiftUI
import CoreData

// Shared: macOS, iOS, tvOS
struct GroupListView: View {
    @State private var path: [InterestGroup] = []
    @State private var selectedGroup: InterestGroup?
    @ObservedObject private var net = NetworkService()
    private let logger = Logger(label: "ContentView.logger")

    var body: some View {
        NavigationStack(path: $path) {
            List(net.groups) { meetupGroup in
                NavigationLink(value: meetupGroup) {
                    // TODO: Visual design
                    Text(meetupGroup.name)
                }
            }
            .navigationTitle("The Coffee")
            .navigationDestination(for: InterestGroup.self) { meetupGroup in
                GroupView(group: meetupGroup)
                    .environmentObject(net)
            }
        }
        .onAppear {
            net.loadGroups()
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GroupListView()
    }
}
#endif
