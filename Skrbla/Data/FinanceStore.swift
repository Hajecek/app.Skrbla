//
//  FinanceStore.swift
//  Skrbla
//
//  Lokální úložiště výdajů a předplatných (UserDefaults).
//  Později se napojí na databázi.
//

import Foundation
import Combine

@MainActor
final class FinanceStore: ObservableObject {
    static let shared = FinanceStore()

    private let expensesKey = "Skrbla.expenses"
    private let subscriptionsKey = "Skrbla.subscriptions"
    private let budgetKey = "Skrbla.monthlyBudget"
    private let dataVersionKey = "Skrbla.dataVersion"
    /// Zvýš při změně, která má jednorázově vymazat lokální data.
    private let currentDataVersion = 1

    @Published var expenses: [Expense] = [] {
        didSet { saveExpenses() }
    }

    @Published var subscriptions: [SubscriptionItem] = [] {
        didSet { saveSubscriptions() }
    }

    @Published var monthlyBudget: Double {
        didSet { UserDefaults.standard.set(monthlyBudget, forKey: budgetKey) }
    }

    private init() {
        if UserDefaults.standard.integer(forKey: dataVersionKey) < currentDataVersion {
            UserDefaults.standard.removeObject(forKey: expensesKey)
            UserDefaults.standard.removeObject(forKey: subscriptionsKey)
            UserDefaults.standard.removeObject(forKey: budgetKey)
            UserDefaults.standard.set(currentDataVersion, forKey: dataVersionKey)
        }

        let savedBudget = UserDefaults.standard.object(forKey: budgetKey) as? Double
        monthlyBudget = savedBudget ?? 0
        load()
    }

    // MARK: - Computed

    var thisMonthExpenses: [Expense] {
        let cal = Calendar.current
        return expenses.filter { cal.isDate($0.date, equalTo: Date(), toGranularity: .month) }
    }

    var thisMonthSpent: Double {
        thisMonthExpenses
            .filter { $0.kind == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    var thisMonthIncome: Double {
        thisMonthExpenses
            .filter { $0.kind == .income }
            .reduce(0) { $0 + $1.amount }
    }

    var activeSubscriptions: [SubscriptionItem] {
        subscriptions.filter(\.isActive).sorted { $0.nextBillingDate < $1.nextBillingDate }
    }

    var monthlySubscriptionsCost: Double {
        activeSubscriptions.reduce(0) { $0 + $1.monthlyCost }
    }

    var budgetProgress: Double {
        guard monthlyBudget > 0 else { return 0 }
        return min(thisMonthSpent / monthlyBudget, 1)
    }

    var remainingBudget: Double {
        max(monthlyBudget - thisMonthSpent, 0)
    }

    var recentExpenses: [Expense] {
        Array(expenses.sorted { $0.date > $1.date }.prefix(8))
    }

    func expensesGroupedByDay() -> [(date: Date, items: [Expense])] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: expenses) { cal.startOfDay(for: $0.date) }
        return grouped
            .map { (date: $0.key, items: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Mutations

    func addExpense(_ expense: Expense) {
        expenses.insert(expense, at: 0)
    }

    func updateExpense(_ expense: Expense) {
        guard let index = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        expenses[index] = expense
    }

    func deleteExpense(id: UUID) {
        expenses.removeAll { $0.id == id }
    }

    func deleteExpenses(at offsets: IndexSet, in list: [Expense]) {
        let ids = offsets.map { list[$0].id }
        expenses.removeAll { ids.contains($0.id) }
    }

    func addSubscription(_ item: SubscriptionItem) {
        subscriptions.insert(item, at: 0)
    }

    func updateSubscription(_ item: SubscriptionItem) {
        guard let index = subscriptions.firstIndex(where: { $0.id == item.id }) else { return }
        subscriptions[index] = item
    }

    func deleteSubscription(id: UUID) {
        subscriptions.removeAll { $0.id == id }
    }

    func clearAllData() {
        expenses = []
        subscriptions = []
        monthlyBudget = 0
    }

    // MARK: - Persistence

    private func load() {
        if let data = UserDefaults.standard.data(forKey: expensesKey),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = decoded
        }
        if let data = UserDefaults.standard.data(forKey: subscriptionsKey),
           let decoded = try? JSONDecoder().decode([SubscriptionItem].self, from: data) {
            subscriptions = decoded
        }
    }

    private func saveExpenses() {
        guard let data = try? JSONEncoder().encode(expenses) else { return }
        UserDefaults.standard.set(data, forKey: expensesKey)
    }

    private func saveSubscriptions() {
        guard let data = try? JSONEncoder().encode(subscriptions) else { return }
        UserDefaults.standard.set(data, forKey: subscriptionsKey)
    }
}
