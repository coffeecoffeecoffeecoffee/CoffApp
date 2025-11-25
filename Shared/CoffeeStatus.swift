//
//  CoffeeStatus.swift
//  CoffApp
//
//  Created by Michael Critz on 11/24/25.
//

enum CoffeeStatus: Equatable {
    case pristine
    case ready
    case processing(progress: Double?)
    case error
}

extension CoffeeStatus: CustomStringConvertible {
    var description: String {
        switch self {
        case .pristine:
            return "Ready"
        case .ready:
            return "Ready"
        case .processing(let progress?):
            return "Processing (\(progress * 100)%)"
        case .processing:
            return "Processing"
        case .error:
            return "An error has occurred"
        }
    }
}
