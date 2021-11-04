import Logging
import SwiftUI

struct EventListView: View {
    @ObservedObject var net = NetworkService()
    var group: InterestGroup
    private let logger = Logger(label: "science.pixel.espresso.eventlistview")

    var body: some View {
            VStack(alignment: .center) {
                if net.netState != .ready {
                    ProgressView(net.netState.description)
                        .padding(30)
                        .frame(minWidth: .none, maxWidth: .infinity, minHeight: 200, maxHeight: 320, alignment: .center)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 30) {
                            if net.upcomingEvents.count > 0 {
                                VStack {
                                    ForEach(net.upcomingEvents, id: \.self) { upcomingEvent in
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
                            if net.pastEvents.count > 0 {
                                Divider()
                                Text("Previously")
                                    .font(.title)
                                ForEach(net.pastEvents) { event in
                                    EventSummaryView(event)
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                    }
            }
        }
        .navigationTitle(group.name)
        .onAppear {
            net.loadEvents(for: group)
            group.setSelected()
        }
        .userActivity(ContentView.contentGroupUserActivityType) { activity in
            logger.info("EVENT LIST: \(activity.activityType)")
            describeUserActivity(activity)
        }
        .onContinueUserActivity(ContentView.contentGroupUserActivityType) { resumeActivity in
            logger.info("CONTINUE: \(resumeActivity.activityType)")
            guard let resumedGroup = try? resumeActivity.typedPayload(InterestGroup.self) else {
                logger.warning("FAIL: Could not resume \(resumeActivity.activityType)")
                return
            }
            logger.info("FOUND: \(resumedGroup.name)")
        }
    }
}

extension EventListView {
    func describeUserActivity(_ userActivity: NSUserActivity) {
        let nextGroup: InterestGroup?
        if let activityGroup = try? userActivity.typedPayload(InterestGroup.self) {
            nextGroup = activityGroup
        } else {
            nextGroup = group
        }
        guard let nextGroup = nextGroup else { return }
        userActivity.title = nextGroup.name
        userActivity.isEligibleForHandoff = true
        userActivity.isEligibleForSearch = true
        userActivity.targetContentIdentifier = nextGroup.id.uuidString
        do {
            try userActivity.setTypedPayload(nextGroup)
        } catch {
            logger.warning("FAIL: Activity Payload for \(nextGroup.name)")
        }
    }
}

#if DEBUG
struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView(group: InterestGroup(id: UUID(uuidString: "28ef50f9-b909-4f03-9a69-a8218a8cbd99")!,
                                   name: "Test Group Name"))
            .environmentObject(NetworkService())
    }
}
#endif
