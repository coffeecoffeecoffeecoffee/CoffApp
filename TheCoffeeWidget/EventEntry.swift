import WidgetKit

struct EventEntry: TimelineEntry {
    var date: Date
    let event: Event
    let imageData: Data?

    init(_ event: Event, date: Date = Date()) {
        self.date = date
        self.event = event
        self.imageData = try? Data.imageData(for: event)
    }
}
