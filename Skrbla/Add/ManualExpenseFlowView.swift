//
//  ManualExpenseFlowView.swift
//  Skrbla
//

import SwiftUI

struct ManualExpenseFlowView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var financeStore: FinanceStore

    @State private var step: Step = .amount
    @State private var amount: Decimal = 0
    @State private var title = ""
    @State private var note = ""
    @State private var category: ExpenseCategory = .other
    @State private var date = Date()

    private enum Step {
        case amount
        case details
    }

    var body: some View {
        Group {
            switch step {
            case .amount:
                ManualAddView(
                    onContinue: { value in
                        amount = value
                        withAnimation(.easeInOut(duration: 0.25)) {
                            step = .details
                        }
                    },
                    onClose: { isPresented = false }
                )
                .preferredColorScheme(.dark)

            case .details:
                NavigationStack {
                    Form {
                        Section("Částka") {
                            Text(SkrblaTheme.formatCurrency(NSDecimalNumber(decimal: amount).doubleValue))
                                .font(.title2.weight(.bold))
                                .foregroundStyle(SkrblaTheme.primary)
                            Button("Upravit částku") {
                                withAnimation { step = .amount }
                            }
                        }

                        Section("Detaily") {
                            TextField("Název", text: $title)
                            TextField("Poznámka", text: $note)
                            Picker("Kategorie", selection: $category) {
                                ForEach(ExpenseCategory.allCases) { item in
                                    Label(item.rawValue, systemImage: item.systemImage).tag(item)
                                }
                            }
                            DatePicker("Datum", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        }
                    }
                    .navigationTitle("Nový výdaj")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Zrušit") { isPresented = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Uložit") { save() }
                                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || amount <= 0)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
    }

    private func save() {
        let expense = Expense(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: NSDecimalNumber(decimal: amount).doubleValue,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            date: date
        )
        financeStore.addExpense(expense)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        isPresented = false
    }
}
