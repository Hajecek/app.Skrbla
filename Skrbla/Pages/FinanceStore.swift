//
//  FinanceStore.swift
//  Skrbla
//
//  Created by Assistant on 21.09.2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class FinanceStore: ObservableObject {
    @Published var monthlySpent: Decimal
    @Published var monthlyBudget: Decimal
    @Published var currencyCode: String
    
    init(
        monthlySpent: Decimal = 12345.67,
        monthlyBudget: Decimal = 20000,
        currencyCode: String = Locale.current.currency?.identifier ?? "CZK"
    ) {
        self.monthlySpent = monthlySpent
        self.monthlyBudget = monthlyBudget
        self.currencyCode = currencyCode
    }
}

extension Decimal {
    var asDouble: Double { NSDecimalNumber(decimal: self).doubleValue }
}

