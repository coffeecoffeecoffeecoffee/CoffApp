//
//  CoffeeErrors.swift
//  CoffApp
//
//  Created by Michael Critz on 11/19/25.
//

enum CoffeeErrors: Error {
    case signInRequired
    case syncError(reason: String)
    case invalid(reason: String)
}
