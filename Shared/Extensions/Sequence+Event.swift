import Foundation

extension Sequence where Element == Event {

    func sortedByTime() -> [Event] {
        let sorted = self.sorted { prev, this in
            guard let prevDate = prev.startAt,
                  let thisDate = this.startAt else { return false }
            return prevDate < thisDate
        }
        return sorted
    }

    private func filtered(isUpcoming: Bool) -> [Event] {
        let now = Date.now
        let filteredEvents = self.filter { thisEvent in
            guard let time = thisEvent.endAt
                    ?? thisEvent.startAt else {
                return false
            }
            return isUpcoming ? time > now : time < now
        }
        return filteredEvents
    }

    func upcoming() -> [Event] {
        let upcoming = self.filtered(isUpcoming: true)
        return upcoming.sortedByTime()
    }

    func past() -> [Event] {
        let past = self.filtered(isUpcoming: false)
        return past.sortedByTime()
    }
}
