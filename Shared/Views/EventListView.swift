import Logging
import SwiftUI

struct EventListView: View {
    @ObservedObject private var profile = UserProfile()
    private let logger = Logger(label: "science.pixel.espresso.eventlistview")

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 30) {
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
            }
            .padding(.horizontal, 15)
        }
        .navigationTitle("Events")
    }
}

#if DEBUG
struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}
#endif
