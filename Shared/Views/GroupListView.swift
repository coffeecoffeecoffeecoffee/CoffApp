import Combine
import Logging
import SwiftUI
import SwiftData

struct GroupListView: View {
    @State private var profile: UserProfile
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor<InterestGroupModel>(\.name, order: .forward)])
    private var groups: [InterestGroupModel]
    private let net: NetworkServicing
    private let logger = Logger(label: "GroupListView.logger")
    
    init(net: NetworkServicing) {
        self.net = net
        self.profile = UserProfile(net: net)
    }
    
    var body: some View {
        List(groups) { groupModel in
            HStack {
                let iconName = groupModel.isSubscribed ? "checkmark.circle.fill" : "circle"
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                Text(groupModel.name)
            }
            .task {
                do {
                    // sync with the server
                    let netGroups = try await net.loadGroups()
                    
                    // find any models not in the net groups
                    let modelsToDelete = groups.filter { groupModel in
                        netGroups.contains { group in
                            groupModel.id != group.id
                        }
                    }
                    
                    // delete groups not on the wire
                    for modelToDelete in modelsToDelete {
                        modelContext.delete(modelToDelete)
                    }
                    
                    // save any new models
                    let modelsToSave = netGroups.filter { netGroup in
                        groups.contains(where: { $0.id == netGroup.id }) == false
                    }
                    
                    for modelToSave in modelsToSave {
                        guard let newModel = InterestGroupModel(from: modelToSave) else {
                            continue
                        }
                        modelContext.insert(newModel)
                    }
                    
                    // Update existing stuff, too…
                    for group in netGroups {
                        if let existingModel = groups.first(where: { $0.id == group.id }) {
                            existingModel.name = group.name
                            existingModel.imageURL = group.imageURL
                        }
                    }
                    
                    try modelContext.save()
                } catch {
                    // TODO: Something! Anything!!
                    fatalError("NOT IMPLEMENTED")
                }
            }
            .onTapGesture {
                groupModel.isSubscribed.toggle()
            }
        }
    }
}

#Preview {
    @Previewable
    var pns = PreviewNetworkService()
    GroupListView(net: pns)
        .modelContainer(for: [InterestGroupModel.self,
                              EventModel.self],
                        inMemory: true)
}

