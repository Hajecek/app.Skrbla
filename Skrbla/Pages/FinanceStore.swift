//
//  FinanceStore.swift
//  Skrbla
//
//  Created by Assistant on 21.09.2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Category Summary (for Home chips)
struct CategorySummary: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    let symbol: String       // SF Symbol (např. "cart.fill")
    let tint: Color          // Barva pilulky/ikony
    let spent: Decimal       // Tento měsíc utraceno
    let budget: Decimal?     // Volitelný měsíční rozpočet (pro progress)
    
    var progress: Double {
        guard let budget else { return 0 }
        let b = NSDecimalNumber(decimal: budget).doubleValue
        guard b > 0 else { return 0 }
        let s = NSDecimalNumber(decimal: spent).doubleValue
        return min(max(s / b, 0), 1)
    }
}

@MainActor
final class FinanceStore: ObservableObject {
    @Published var monthlySpent: Decimal
    @Published var monthlyBudget: Decimal
    @Published var currencyCode: String
    
    // Top kategorie pro Home (demo data; v reálnu načíst z DB/analytiky)
    @Published var topCategories: [CategorySummary]
    
    init(
        monthlySpent: Decimal = 12345.67,
        monthlyBudget: Decimal = 20000,
        currencyCode: String = Locale.current.currency?.identifier ?? "CZK",
        topCategories: [CategorySummary]? = nil
    ) {
        self.monthlySpent = monthlySpent
        self.monthlyBudget = monthlyBudget
        self.currencyCode = currencyCode
        
        // Demo kategorie (pokud nepřijdou zvenku)
        self.topCategories = topCategories ?? [
            CategorySummary(name: "Potraviny", symbol: "cart.fill", tint: .green, spent: 3850, budget: 6000),
            CategorySummary(name: "Doprava", symbol: "car.fill", tint: .blue, spent: 1120, budget: 2000),
            CategorySummary(name: "Stravování", symbol: "fork.knife", tint: .orange, spent: 2480, budget: 3000),
            CategorySummary(name: "Zábava", symbol: "gamecontroller.fill", tint: .purple, spent: 980, budget: 2000),
            CategorySummary(name: "Nákupy", symbol: "bag.fill", tint: .pink, spent: 1650, budget: 2500),
            CategorySummary(name: "Služby", symbol: "wrench.and.screwdriver.fill", tint: .teal, spent: 750, budget: 1800)
        ]
    }
}

extension Decimal {
    var asDouble: Double { NSDecimalNumber(decimal: self).doubleValue }
}

