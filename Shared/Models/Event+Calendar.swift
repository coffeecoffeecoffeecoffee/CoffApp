//
//  Event+Calendar.swift
//  CoffApp
//
//  Created by Michael Critz on 6/27/22.
//

import Foundation

extension Event {
    func shareURL() -> URL {
        guard let groupID else {
            return URL.baseURL
        }
        return URL.groupURL(groupID)
    }
}
