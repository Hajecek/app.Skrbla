//
//  SkrblaWidgetAttributes.swift
//  SkrblaWidget
//
//  Musí existovat ve widget extension i v hlavní app (ActivityKit).
//

import ActivityKit
import Foundation

struct SkrblaWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentAmount: Double
        var monthlyGoal: Double
        var lastTransaction: String
        var lastTransactionAmount: Double
        var isPositive: Bool
        var category: String
    }

    var name: String
}
