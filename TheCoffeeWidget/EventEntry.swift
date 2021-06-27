import WidgetKit

struct EventEntry: TimelineEntry {
    var date: Date
    let event: Event
    let configuration: ConfigurationIntent
}
