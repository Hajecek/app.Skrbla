//
//  LiveActivityManager.swift
//  Skrbla
//
//  Created by Michal Hájek on 15.09.2025.
//

import ActivityKit
import Foundation

// Definice atributů pro Live Activity
struct SkrblaWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var currentAmount: Double
        var monthlyGoal: Double
        var lastTransaction: String
        var lastTransactionAmount: Double
        var isPositive: Bool
        var category: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<SkrblaWidgetAttributes>?
    
    private init() {}
    
    func startActivity() {
        // Definujeme počáteční stav
        let initialState = SkrblaWidgetAttributes.ContentState(
            currentAmount: 12500.0,
            monthlyGoal: 20000.0,
            lastTransaction: "Nákup v obchodě",
            lastTransactionAmount: 250.0,
            isPositive: false,
            category: "Potraviny"
        )
        
        // Fixní atributy
        let attributes = SkrblaWidgetAttributes(name: "Skrbla")
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil // Lokální update (ne přes push)
            )
            print("✅ Live Aktivita spuštěna: \(String(describing: currentActivity?.id))")
        } catch {
            print("❌ Nepodařilo se spustit Live Aktivitu: \(error)")
        }
    }
    
    func updateActivity(currentAmount: Double, lastTransaction: String, amount: Double, isPositive: Bool, category: String) {
        Task {
            let updatedState = SkrblaWidgetAttributes.ContentState(
                currentAmount: currentAmount,
                monthlyGoal: 20000.0,
                lastTransaction: lastTransaction,
                lastTransactionAmount: amount,
                isPositive: isPositive,
                category: category
            )
            
            await currentActivity?.update(using: updatedState)
            print("🔄 Aktivita aktualizována")
        }
    }
    
    func endActivity() {
        Task {
            await currentActivity?.end(dismissalPolicy: .immediate)
            print("🛑 Aktivita ukončena")
            currentActivity = nil
        }
    }
}
