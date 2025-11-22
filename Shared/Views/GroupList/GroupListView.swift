import Combine
import Logging
import SwiftUI
import SwiftData

struct GroupListView: View {
    @EnvironmentObject var profile: UserProfile
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor<InterestGroupModel>(\.name, order: .forward)])
    private var groups: [InterestGroupModel]
    
    private let logger = Logger(label: "GroupListView.logger")

    var body: some View {
        List(groups) { groupModel in
            HStack {
                let proxy = InterestGroup(id: groupModel.id, name: groupModel.name, imageURL: groupModel.imageURL)
                let iconName = profile.subscribedTo(proxy) ? "checkmark.circle.fill" : "circle"
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                Text(groupModel.name)
            }
            .onTapGesture {
                let proxy = InterestGroup(id: groupModel.id, name: groupModel.name, imageURL: groupModel.imageURL)
                do {
                    try profile.toggleGroup(proxy)
                } catch {
                    logger.error(.init(stringLiteral: error.localizedDescription))
                }
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GroupListView()
            .environmentObject(UserProfile())
    }
}
#endif

