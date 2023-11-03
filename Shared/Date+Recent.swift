//
//  Date+Recent.swift
//  CoffApp
//
//  Created by Michael Critz on 10/12/22.
//

import Foundation

extension Date {
    func isNearFuture(_ days: Int = 2) -> Bool {
        // TODO: Better handling here with time zones and DateComponent and whatnot
        let secondsIn24Hours = 86_400
        let recencyRangeInSeconds = (-secondsIn24Hours * days)...0
        let secondsFromNow = Int(self.timeIntervalSinceNow) // which is negative if the future
        if recencyRangeInSeconds.contains(secondsFromNow) {
            return true
        }
        return false
    }
}
