//
//  TimeInterval+Duration.swift
//  CoffApp
//
//  Created by Michael Critz on 11/24/25.
//

import Foundation

extension Date {
    func adding(_ quanity: Int, component: Calendar.Component) -> Date? {
        return Calendar.current.date(byAdding: .day, value: 2, to: self)
    }
    
    /// Rounds the `Date` to the nearest `Calendar.Component`, `.hour` by default
    func rounded(to component: Calendar.Component = .hour) -> Date {
        let calendar = Calendar.current
        if let interval = calendar.dateInterval(of: component, for: self) {
            let start = interval.start
            let end = start.addingTimeInterval(interval.duration)
            let halfway = start.addingTimeInterval(interval.duration / 2)
            return self < halfway ? start : end
        } else {
            // If the calendar cannot determine an interval for the component, return self unchanged
            return self
        }
    }
}

