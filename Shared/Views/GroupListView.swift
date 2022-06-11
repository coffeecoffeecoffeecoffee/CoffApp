import Logging
import SwiftUI
import CoreData

struct GroupListView: View {
    @State private var groups: [InterestGroup] = []
    private let logger = Logger(label: "GroupListView.logger")
    private let profile = UserProfile()
    private let groupsURL = URL.appURL(with: "api", "groups")

    var body: some View {
        List(groups) { meetupGroup in
            HStack {
                let iconName = profile.subscribedTo(meetupGroup) ? "checkmark.circle.fill" : "circle"
                Image(systemName: iconName)
                Text(meetupGroup.name)
            }
            .onTapGesture {
                do {
                    try profile.toggleGroup(meetupGroup)
                } catch {
                    logger.error(.init(stringLiteral: error.localizedDescription))
                }
            }
        }
        .navigationTitle("Groups")
        .task {
            do {
                let (groupsData, _) = try await URLSession.shared.data(from: groupsURL)
                groups = try JSONDecoder().decode([InterestGroup].self,
                                              from: groupsData)
            } catch {
                logger.error(.init(stringLiteral: error.localizedDescription))
            }
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
