import Foundation

enum SortOrder {
    case oldestFirst
    case newestFirst
}

extension Collection where Element == Event {
    func sorted(orderedBy sortOrder: SortOrder = .newestFirst) -> [Event] {
        let sorted = self.sorted { prev, this in
            guard let prevDate = prev.startAt,
                  let thisDate = this.startAt else { return false }
            switch sortOrder {
            case .oldestFirst:
                return prevDate < thisDate
            default:
                return prevDate > thisDate
            }
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
        return upcoming.sorted(orderedBy: .oldestFirst)
    }

    func past() -> [Event] {
        let past = self.filtered(isUpcoming: false)
        return past.sorted()
    }

    func matching(term: String) throws -> [Event] {
        let regex = try Regex(term.lowercased())
        let matches = try self.filter { event in
            try regex.firstMatch(in: event.name.lowercased()) != nil
            || regex.firstMatch(in: event.venueName.lowercased()) != nil
            || regex.firstMatch(in: event.localizedStartTime().lowercased()) != nil
        }
        return matches.sorted()
    }
}
