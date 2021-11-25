import Logging
import SwiftUI
import CoreData

// Shared: macOS, iOS, tvOS
struct ContentView: View {
    private var net = NetworkService()
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var groups = Groups()
    @SceneStorage("selectedGroup") var selectedGroup: String?
    static let contentGroupUserActivityType = "science.pixel.espresso.group"
    private let logger = Logger(label: "ContentView.logger")

    var body: some View {
        NavigationView {
            List {
                // This is needed only for iOS because the source side
                // of List is sometimes the only view visible on iPhone
                #if os(iOS)
                if net.netState == .loading
                    && UIDevice.current.userInterfaceIdiom != .pad {
                    StatusView()
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity)
                        .padding()
                }
                #endif
                ForEach(groups.groups) { group in
                    NavigationLink(group.name,
                                   destination: EventListView(group: group),
                                   tag: group.name,
                                   selection: $selectedGroup)
                }
            }
            .navigationTitle("The Coffee")
            switch groups.state {
            case .loading:
                ProgressView(net.netState.description)
                    .frame(minWidth: 320, minHeight: 180)
            case .failed(let error):
                let errorViewModel = StatusViewModel(headline: "Network Error",
                                                     description: error.localizedDescription,
                                                     symbolName: "xmark.icloud")
                StatusView(errorViewModel)
                    .padding()
            default:
                Text("Choose a group")
                    .font(.largeTitle)
            }
        }
        .toolbar {
            #if os(OSX)
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.left")
                })
            }
            #endif
        }
        .onAppear {
            net.loadGroups()
        }
        .onContinueUserActivity(ContentView.contentGroupUserActivityType) { resumeActivity in
            logger.debug("CONTINUE: \(resumeActivity.activityType)")
            guard let resumedGroup = try? resumeActivity.typedPayload(InterestGroup.self) else {
                return
            }
            logger.debug("GOT \(resumedGroup.name)")
            net.loadGroups()
            groups.select(resumedGroup.name)
        }
    }
}

extension ContentView {
    func describeUserActivity(_ userActivity: NSUserActivity) {
        let nextGroup: InterestGroup?
        if let activityGroup = try? userActivity.typedPayload(InterestGroup.self) {
            nextGroup = activityGroup
        } else {
            nextGroup = groups.selectedGroup
        }
        guard let nextGroup = nextGroup else { return }
        userActivity.title = nextGroup.name
        userActivity.isEligibleForHandoff = true
        userActivity.isEligibleForSearch = true
        userActivity.targetContentIdentifier = nextGroup.id.uuidString
        try? userActivity.setTypedPayload(nextGroup)
    }
}

extension ContentView {
    #if os(OSX)
    public func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?
            .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    #endif
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext,
                                  PersistenceController.preview.container.viewContext)
    }
}
#endif
