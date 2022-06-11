import Logging
import SwiftUI

struct EventListView: View {
    @ObservedObject private var profile = UserProfile()
    private let logger = Logger(label: "science.pixel.espresso.eventlistview")
    @State private var queryString = ""
    @State private var filteredEvents = [Event]()
    private func filter(events: [Event]) -> [Event] {
        do {
            return try events.matches(term: queryString)
        } catch {
            return []
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 30) {
                    if queryString.isEmpty {
                        if !profile.hasGroups {
                            GroupListView()
                                .frame(maxWidth: .infinity, minHeight: 300)
                                .padding()
                                .background(Color.red)
                        }
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
                        let matchedEvents = filter(events: profile.events)
                        Text("Events: \(matchedEvents.count)")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        ForEach(matchedEvents) { event in
                            EventSummaryView(event)
                        }
                    }
                }
                .padding()
                .navigationTitle("The Coffee")
                .searchable(text: $queryString)
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
