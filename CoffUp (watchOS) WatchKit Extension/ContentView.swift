import SwiftUI

struct ContentView: View {
    @EnvironmentObject var networkService: NetworkService
    var body: some View {
        ForEach(networkService.groups) { group in
            List(networkService.groups, id: \.id) { group in
                NavigationLink(group.name, destination: EventListView(networkService: networkService, group: group))
            }
        }
        .onAppear(perform: {
            networkService.loadGroups()
        })
    }
}

struct EventListView: View {
    var networkService: NetworkService
    var group: Group
    
    var body: some View {
        VStack {
            Text(group.name)
                .bold()
            List(networkService.events) { event in
                Text(event.name)
                    .font(.body)
            }
        }
        .onAppear(perform: {
            networkService.loadEvents(for: group)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
