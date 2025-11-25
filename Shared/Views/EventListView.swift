import BackgroundTasks
import Logging
import SwiftUI

struct EventListView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var profile = UserProfile()
    internal let logger = Logger(label: "science.pixel.espresso.eventlistview")
    @State private var showingPopover = false
    @Namespace private var namespace
    @State private var groups = [InterestGroup]()
    @State private var status: CoffeeStatus = .pristine

    var body: some View {
        ZStack(alignment: .topTrailing) {
            GeometryReader { geo in
                ScrollView {
                    if status == CoffeeStatus.error {
                        StatusView("An error has occurred",
                                   description: "Try again later",
                                   symbolName: "exclamationmark.triangle")
                    } else {
                        LazyVStack(alignment: .leading, spacing: 30) {
                            if !profile.hasGroups {
                                HStack(alignment: .center) {
                                    StatusView(
                                        "No groups selected",
                                        description: "Please choose some groups to find local events",
                                        symbolName: "person.2"
                                    )
                                    .frame(height: geo.size.height * 0.85,
                                           alignment: .center)
                                    #if os(macOS)
                                    .buttonStyle(.link)
                                    #endif
                                }
                                .padding(.horizontal)
                            } else if profile.queryString.isEmpty {
                                if profile.upcomingEvents.count > 0 {
                                    LazyVGrid(columns: [
                                        GridItem(.adaptive(minimum: 560, maximum: geo.size.width))
                                    ]) {
                                        ForEach(profile.upcomingEvents, id: \.self) { upcomingEvent in
                                            EventDetailView(upcomingEvent)
                                                .frame(
                                                    minWidth: 300,
                                                    idealWidth: geo.size.width,
                                                    minHeight: (geo.size.height * 0.667)
                                                )
                                        }
                                    }
                                } else {
                                    Spacer()
                                    HStack {
                                        StatusView(
                                            "No upcoming Events",
                                            description: "Check back later",
                                            symbolName: "calendar"
                                        )
                                        .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .frame(height: geo.size.height,
                                           alignment: .center)
                                }
                                if profile.pastEvents.count > 0 {
                                    Group {
                                        Text("Previously")
                                            .font(.title)
                                        LazyVGrid(
                                            columns: [
                                                GridItem(.adaptive(minimum: 280, maximum: 560))
                                            ],
                                            alignment: .leading,
                                            spacing: 24
                                        ) {
                                            ForEach(profile.pastEvents) { event in
                                                EventSummaryView(event)
                                                    .padding(.bottom, 24)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            } else {
                                NavigationStack {
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
                        }
                        .ignoresSafeArea(.all, edges: [.top])
                        .padding(.bottom, 40)
                        .task {
                            do {
                                try await profile.sync()
                            } catch let coffeeError as CoffeeErrors {
                                logger.error("\(String(describing: coffeeError))")
                                return
                            } catch {
                                logger.error(.init(stringLiteral: error.localizedDescription))
                                
                            }
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
            .ignoresSafeArea(.all, edges: [.top])
            .frame(minWidth: 332)
            Menu {
                ForEach(groups) { group in
                    Toggle(
                        group.name,
                        isOn: Binding(
                            get: {
                                profile.subscribedTo(group)
                            },
                            set: { _ in
                                try? profile.toggleGroup(group)
                            }
                        )
                    )
                }
            } label: {
                if #available(iOS 26.0, macOS 26.0, *) {
                    Image(systemName: "person.2.fill")
                        .padding()
                        .tint(.accentColor)
                        .glassEffect(.regular, in: .circle)
                        .padding()
                        .task {
                            do {
                                groups = try await InterestGroup.fetchGroups()
                            } catch {
                                logger.error("\(String(describing: error))")
                            }
                        }
                } else {
                    Image(systemName: "line.3.horizontal.decrease")
                        .padding()
                        .tint(.primary)
                        .background {
                            Circle()
                                .fill(.thinMaterial)
                        }
                        .padding()
                        .task {
                            do {
                                groups = try await InterestGroup.fetchGroups()
                            } catch {
                                logger.error("\(String(describing: error))")
                            }
                        }
                }
            }
            //            } else {
            //                Button {
            //                    showingPopover = true
            //                } label: {
            //                    Image(systemName: "line.3.horizontal.decrease")
            //                }
            //            }
        }
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
