import Logging
import SwiftUI

struct EventListView: View {
    @StateObject private var profile = UserProfile()
    private let logger = Logger(label: "science.pixel.espresso.eventlistview")
    @State private var showingPopover = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 30) {
                        if !profile.hasGroups {
                            HStack(alignment: .center) {
                                Spacer()
                                Button {
                                    showingPopover.toggle()
                                } label: {
                                    HStack {
                                        Image(systemName: "person.2.circle")
                                        Text("No groups selected")
                                    }
                                }
#if os(macOS)
                                .buttonStyle(.link)
#endif
                                .font(.largeTitle)
                                .foregroundColor(.accentColor)
                                .padding(.vertical, 70)
                                Spacer()
                            }
                            .padding(.horizontal)
                        } else if profile.queryString.isEmpty {
                            if profile.upcomingEvents.count > 0 {
                                ScrollView(.horizontal) {
                                    LazyHGrid(rows: [
                                        GridItem(.adaptive(minimum: 560, maximum: (geo.size.width - 32)))
                                                ]) {
                                        ForEach(profile.upcomingEvents, id: \.self) { upcomingEvent in
                                            EventDetailView(upcomingEvent)
                                                .frame(idealWidth: geo.size.width - 32,
                                                       minHeight: 360,
                                                       maxHeight: 360)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .frame(height: 360)
                            } else {
                                HStack {
                                    Spacer()
                                    Text("No upcoming events")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding()
                            }
                            if profile.pastEvents.count > 0 {
                                Group {
                                    Divider()
                                    Text("Previously")
                                        .font(.title)
                                    LazyVGrid(columns: [
                                                        GridItem(.adaptive(minimum: 280, maximum: 560))
                                                    ],
                                              alignment: .leading,
                                              spacing: 24) {
                                        ForEach(profile.pastEvents) { event in
                                            EventSummaryView(event)
                                                .padding(.bottom, 24)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            Group {
                                Text("Events: \(profile.filteredEvents.count)")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                ForEach(profile.filteredEvents) { event in
                                    EventSummaryView(event)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 40)
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
#if os(iOS)
                                    .navigationTitle("Groups")
                                    .navigationBarTitleDisplayMode(.inline)
                                    .toolbar {
                                        Button {
                                            showingPopover.toggle()
                                        } label: {
                                            Text("Done")
                                        }
                                    }
#endif
                            }
                            .frame(minWidth: 250, minHeight: 240, idealHeight: 304)
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
