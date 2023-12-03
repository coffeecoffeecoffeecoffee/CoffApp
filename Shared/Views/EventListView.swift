import Logging
import BackgroundTasks
import SwiftUI

struct EventListView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var profile = UserProfile()
    internal let logger = Logger(label: "science.pixel.espresso.eventlistview")
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
                                    StatusView("No groups selected",
                                               description: "Please choose some groups to find local events",
                                               symbolName: "person.2.circle")
                                }
#if os(macOS)
                                .buttonStyle(.link)
#endif
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
                                                .frame(
                                                    minWidth: 300,
                                                    idealWidth: geo.size.width - 32,
                                                    minHeight: (geo.size.height / 2),
                                                    maxHeight: (geo.size.height / 1.2))
                                        }
                                    }
                                    .scrollTargetLayout()
                                    .padding(.horizontal)
                                }
                                .scrollTargetBehavior(.viewAligned)
                            } else {
                                HStack {
                                    Spacer()
                                    StatusView("No upcoming Events",
                                               description: "Check back later",
                                               symbolName: "calendar")
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
                            .presentationDetents([.medium, .large])
                            .frame(minWidth: 250, minHeight: 240, idealHeight: 304)
                        }
                    }
                }
                .refreshable {
                    do {
                        try await profile.sync()
                    } catch {
                        logger.error(.init(stringLiteral: error.localizedDescription))
                    }
                }
            }
        }
        .frame(minWidth: 332)
        .onReceive(NotificationCenter.default.publisher(for: .init("science.pixel.espresso.refresh-view"))) { _ in
            Task {
                do {
                    try await profile.sync()
                } catch {
                    logger.error(.init(stringLiteral: error.localizedDescription))
                }
            }
        }
#if os(iOS)
        .onChange(of: scenePhase) { _, newValue in
            switch newValue {
            case .active:
                Task {
                    do {
                        try await removeBadgeCount()
                    } catch {
                        logger.error(.init(stringLiteral: error.localizedDescription))
                    }
                }
            default:
                break
            }
        }
        .task {
            scheduleAppRefresh()
        }
#endif
    }
}

#if DEBUG
struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}
#endif
