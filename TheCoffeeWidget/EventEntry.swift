import WidgetKit

struct EventEntry: TimelineEntry {
    var date: Date
    let event: Event
    let imageData: Data?
    let configuration: ConfigurationIntent

    init(_ event: Event, date: Date = Date(), configuration: ConfigurationIntent = ConfigurationIntent()) {
        self.configuration = configuration
        self.date = date
        self.event = event
        self.imageData = try? Data.imageData(for: event)
    }
}
