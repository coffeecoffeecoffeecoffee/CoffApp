import SwiftUI
import CoreData

// Shared: macOS, iOS, tvOS
struct ContentView: View {
    @ObservedObject private var networkService = NetworkService()
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var groups = Groups()
    @SceneStorage("selectedGroupName") var selectedGroupName = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(groups.groups) { group in
                    NavigationLink(group.name,
                                   destination: EventListView(group: group),
                                   isActive: selectionBinding(for: group.name))
                        .tag(group.name)
                }
            }
            .navigationTitle("The Coffee")
            if groups.state == .loading {
                ProgressView(networkService.netState.description)
                    .frame(minWidth: 320, minHeight: 180)
            } else if networkService.netState != .ready {
                Text(networkService.netState.description)
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
    }
}

extension ContentView {
    func selectionBinding(for name: String) -> Binding<Bool> {
        Binding<Bool> { () -> Bool in
            self.selectedGroupName == name
        } set: { newValue in
            if newValue {
                self.selectedGroupName = name
            } else {
                #if os(iOS)
                // not necessary for anything other than iOS
                // and macOS in particular has a bug for
                // navigation view selection
                self.selectedGroupName = ""
                #endif
            }
        }
    }

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
