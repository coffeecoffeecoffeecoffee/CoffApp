import Logging
import SwiftUI
import CoreData

// Shared: macOS, iOS, tvOS
struct ContentView: View {
    @StateObject private var networkService = NetworkService()
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var groups = Groups()
    @SceneStorage("selectedGroup") var selectedGroup: String?
    static let contentGroupUserActivityType = "science.pixel.espresso.group"
    private let logger = Logger(label: "ContentView.logger")

    var body: some View {
        NavigationView {
            List {
                #if os(iOS)
                if networkService.netState != .ready
                    && networkService.netState != .loading
                    && UIDevice.current.userInterfaceIdiom != .pad {
                    ErrorView(headline: "Network Error",
                              description: networkService.netState.description,
                              symbolName: "xmark.icloud")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            if groups.state == .loading {
                ProgressView(networkService.netState.description)
                    .frame(minWidth: 320, minHeight: 180)
            } else if networkService.netState != .ready {
                ErrorView(headline: "Network Error",
                          description: networkService.netState.description,
                          symbolName: "xmark.icloud")
                    .padding()
            } else {
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
            networkService.loadGroups()
        }
        .onContinueUserActivity(ContentView.contentGroupUserActivityType) { resumeActivity in
            logger.info("CONTINUE: \(resumeActivity.activityType)")
            guard let resumedGroup = try? resumeActivity.typedPayload(Group.self) else {
                return
            }
            logger.info("GOT \(resumedGroup.name)")
            groups.select(resumedGroup.name)
        }
    }
}

extension ContentView {
    func describeUserActivity(_ userActivity: NSUserActivity) {
        let nextGroup: Group?
        if let activityGroup = try? userActivity.typedPayload(Group.self) {
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

extension ContentView {
    private func addItem() {
        withAnimation {
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext,
                                  PersistenceController.preview.container.viewContext)
    }
}
#endif
