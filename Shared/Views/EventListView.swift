import Logging
import SwiftUI

struct EventListView: View {
    @StateObject private var profile = UserProfile()
    private let logger = Logger(label: "science.pixel.espresso.eventlistview")
    @State private var showingPopover = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 30) {
                    if !profile.hasGroups {
                        HStack(alignment: .center) {
                            Spacer()
                            Button("No groups selected") {
                                showingPopover.toggle()
                            }
                            Spacer()
                        }
                    } else if profile.queryString.isEmpty {
                        if profile.upcomingEvents.count > 0 {
                            VStack {
                                ForEach(profile.upcomingEvents, id: \.self) { upcomingEvent in
                                    EventDetailView(upcomingEvent)
                                }
                            }
                        } else {
                            HStack {
                                Text("No upcoming events")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        if profile.pastEvents.count > 0 {
                            Divider()
                            Text("Previously")
                                .font(.title)
                            ForEach(profile.pastEvents) { event in
                                EventSummaryView(event)
                            }
                        }
                    } else {
                        Text("Events: \(profile.filteredEvents.count)")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        ForEach(profile.filteredEvents) { event in
                            EventSummaryView(event)
                        }
                    }
                }
                .padding()
                .navigationTitle("The Coffee")
                .searchable(text: $profile.queryString)
                .task {
                    do {
                        try await profile.sync()
                    } catch {
                        logger.error(.init(stringLiteral: error.localizedDescription))
                        fatalError(error.localizedDescription)
                    }
                }
                .toolbar {
#if DEBUG
                    Button {
                        Task {
                            do {
                                try await profile.sync()
                            } catch {
                                logger.error(.init(stringLiteral: error.localizedDescription))
                                fatalError(error.localizedDescription)
                            }
                        }
                    } label: {
                        Text("Sync")
                    }
#endif
                    Button {
                        showingPopover.toggle()
                    } label: {
                        Image(systemName: "person.2.circle")
                        Text("Groups")
                    }
                    .popover(isPresented: $showingPopover) {
                        NavigationStack {
                            GroupListView()
                                .environmentObject(profile)
                                .navigationTitle("Groups")
#if os(iOS)
                                .navigationBarTitleDisplayMode(.inline)
#endif
                                .toolbar {
                                    Button {
                                        showingPopover.toggle()
                                    } label: {
                                        Text("Done")
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}
#endif
