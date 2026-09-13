//
//  SubscriptionView.swift
//  Skrbla
//

import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject private var authState: AuthState
    @EnvironmentObject private var financeStore: FinanceStore
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Měsíční náklady")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(SkrblaTheme.formatCurrency(financeStore.monthlySubscriptionsCost))
                                .font(.title2.weight(.bold))
                        }
                        Spacer()
                        Image(systemName: "calendar.badge.clock")
                            .font(.title2)
                            .foregroundStyle(SkrblaTheme.accent)
                    }
                    .padding(.vertical, 4)
                }

                Section("Aktivní") {
                    if financeStore.activeSubscriptions.isEmpty {
                        ContentUnavailableView(
                            "Žádná předplatná",
                            systemImage: "calendar",
                            description: Text("Přidej Netflix, Spotify a další.")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(financeStore.activeSubscriptions) { item in
                            NavigationLink {
                                SubscriptionEditorView(item: item)
                            } label: {
                                SubscriptionRowView(item: item)
                            }
                        }
                        .onDelete { offsets in
                            let ids = offsets.map { financeStore.activeSubscriptions[$0].id }
                            ids.forEach(financeStore.deleteSubscription)
                        }
                    }
                }

                let inactive = financeStore.subscriptions.filter { !$0.isActive }
                if !inactive.isEmpty {
                    Section("Neaktivní") {
                        ForEach(inactive) { item in
                            NavigationLink {
                                SubscriptionEditorView(item: item)
                            } label: {
                                SubscriptionRowView(item: item)
                                    .opacity(0.65)
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
                        .opacity(0.45)
                }
            }
            .navigationTitle("Předplatné")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ProfileBarButton()
                }
            }
            .sheet(isPresented: $showAdd) {
                NavigationStack {
                    SubscriptionEditorView(item: nil)
                }
            }
        }
    }
}

struct SubscriptionRowView: View {
    let item: SubscriptionItem

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(SkrblaTheme.accent.opacity(0.18))
                Image(systemName: "calendar")
                    .foregroundStyle(SkrblaTheme.accent)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body.weight(.semibold))
                Text("Další platba \(SkrblaTheme.formatDate(item.nextBillingDate, style: .medium))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(SkrblaTheme.formatCurrency(item.amount))
                    .font(.body.weight(.semibold))
                Text(item.cycle.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct SubscriptionEditorView: View {
    @EnvironmentObject private var financeStore: FinanceStore
    @Environment(\.dismiss) private var dismiss

    let item: SubscriptionItem?

    @State private var name = ""
    @State private var amountText = ""
    @State private var cycle: BillingCycle = .monthly
    @State private var nextBillingDate = Date()
    @State private var isActive = true
    @State private var note = ""

    private var isEditing: Bool { item != nil }

    var body: some View {
        Form {
            Section("Předplatné") {
                TextField("Název", text: $name)
                TextField("Částka", text: $amountText)
                    .keyboardType(.decimalPad)
                Picker("Cyklus", selection: $cycle) {
                    ForEach(BillingCycle.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                DatePicker("Další platba", selection: $nextBillingDate, displayedComponents: .date)
                Toggle("Aktivní", isOn: $isActive)
            }
            Section("Poznámka") {
                TextField("Volitelná poznámka", text: $note)
            }
            Section {
                Button(isEditing ? "Uložit" : "Přidat") {
                    save()
                }
                .fontWeight(.semibold)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || parsedAmount <= 0)

                if isEditing {
                    Button("Smazat", role: .destructive) {
                        if let id = item?.id {
                            financeStore.deleteSubscription(id: id)
                        }
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle(isEditing ? "Upravit" : "Nové předplatné")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Zavřít") { dismiss() }
            }
        }
        .onAppear {
            guard let item else { return }
            name = item.name
            amountText = String(format: "%.0f", item.amount)
            cycle = item.cycle
            nextBillingDate = item.nextBillingDate
            isActive = item.isActive
            note = item.note
        }
    }

    private var parsedAmount: Double {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        return Double(normalized) ?? 0
    }

    private func save() {
        let model = SubscriptionItem(
            id: item?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: parsedAmount,
            cycle: cycle,
            nextBillingDate: nextBillingDate,
            isActive: isActive,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        if item == nil {
            financeStore.addSubscription(model)
        } else {
            financeStore.updateSubscription(model)
        }
        dismiss()
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(AuthState())
        .environmentObject(FinanceStore.shared)
}
