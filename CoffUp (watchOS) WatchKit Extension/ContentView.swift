import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var networkService: NetworkService
    var body: some View {
        ForEach(networkService.groups) { group in
            List(networkService.groups, id: \.id) { group in
                NavigationLink(group.name, destination: EventListView(group: group))
            }
        }
        .onAppear(perform: {
            networkService.loadGroups()
        })
    }
}

struct EventListView: View {
    var group: Group
    
    var body: some View {
        VStack {
            Text("Groups")
            
            Text(group.name)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
