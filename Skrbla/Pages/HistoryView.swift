//
//  HistoryView.swift
//  Skrbla
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var authState: AuthState
    @EnvironmentObject private var financeStore: FinanceStore
    @Environment(\.openAddSheet) private var openAddSheet
    @State private var selectedCategory: ExpenseCategory?
    @State private var searchText = ""

    private var filteredGroups: [(date: Date, items: [Expense])] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return financeStore.expensesGroupedByDay().compactMap { group in
            let items = group.items.filter { expense in
                let categoryOK = selectedCategory == nil || expense.category == selectedCategory
                let searchOK = query.isEmpty
                    || expense.title.lowercased().contains(query)
                    || expense.note.lowercased().contains(query)
                return categoryOK && searchOK
            }
            guard !items.isEmpty else { return nil }
            return (date: group.date, items: items)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if filteredGroups.isEmpty {
                    ContentUnavailableView(
                        "Žádná historie",
                        systemImage: "clock",
                        description: Text("Zatím tu nejsou žádné výdaje.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(filteredGroups, id: \.date) { group in
                        Section(SkrblaTheme.formatDayHeader(group.date)) {
                            ForEach(group.items) { expense in
                                NavigationLink {
                                    ExpenseDetailView(expense: expense)
                                } label: {
                                    ExpenseRowView(expense: expense)
                                }
                            }
                            .onDelete { offsets in
                                financeStore.deleteExpenses(at: offsets, in: group.items)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background {
                ZStack(alignment: .top) {
                    Color(uiColor: .systemGroupedBackground)
                    HomeTopArchGlow()
                        .ignoresSafeArea(edges: .top)
                        .allowsHitTesting(false)
                        .opacity(0.55)
                }
            }
            .navigationTitle("Historie")
            .searchable(text: $searchText, prompt: "Hledat výdaj")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("Všechny kategorie") { selectedCategory = nil }
                        Divider()
                        ForEach(ExpenseCategory.allCases) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                Label(category.rawValue, systemImage: category.systemImage)
                            }
                        }
                    } label: {
                        Image(systemName: selectedCategory == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ProfileBarButton()
                }
            }
        }
    }
}

struct ExpenseDetailView: View {
    @EnvironmentObject private var financeStore: FinanceStore
    @Environment(\.dismiss) private var dismiss
    @State var expense: Expense
    @State private var amountText = ""
    @State private var showDeleteConfirm = false

    private var canSave: Bool {
        let titleOK = !expense.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return titleOK && parsedAmount != nil
    }

    private var parsedAmount: Double? {
        let normalized = amountText
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value > 0 else { return nil }
        return value
    }

    var body: some View {
        Form {
            Section {
                Picker("Typ", selection: $expense.kind) {
                    ForEach(ExpenseKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                TextField("Částka", text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(expense.kind == .income ? SkrblaTheme.primary : .primary)
            } header: {
                Text("Částka")
            } footer: {
                Text(expense.kind == .income ? "Příjem navyšuje zůstatek." : "Výdaj se odečítá z rozpočtu.")
            }

            Section("Detaily") {
                TextField("Název", text: $expense.title)
                TextField("Poznámka", text: $expense.note)
                Picker("Kategorie", selection: $expense.category) {
                    ForEach(ExpenseCategory.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                DatePicker("Datum", selection: $expense.date)
            }
            Section {
                Button("Uložit změny") {
                    guard let amount = parsedAmount else { return }
                    expense.amount = amount
                    expense.title = expense.title.trimmingCharacters(in: .whitespacesAndNewlines)
                    expense.note = expense.note.trimmingCharacters(in: .whitespacesAndNewlines)
                    financeStore.updateExpense(expense)
                    dismiss()
                }
                .disabled(!canSave)
                .fontWeight(.semibold)

                Button("Smazat", role: .destructive) {
                    showDeleteConfirm = true
                }
            }
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            amountText = formatAmountForEditing(expense.amount)
        }
        .alert("Smazat záznam?", isPresented: $showDeleteConfirm) {
            Button("Smazat", role: .destructive) {
                financeStore.deleteExpense(id: expense.id)
                dismiss()
            }
            Button("Zrušit", role: .cancel) {}
        }
    }

    private func formatAmountForEditing(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.2f", value).replacingOccurrences(of: ".", with: ",")
    }
}

#Preview {
    HistoryView()
        .environmentObject(AuthState())
        .environmentObject(FinanceStore.shared)
}
