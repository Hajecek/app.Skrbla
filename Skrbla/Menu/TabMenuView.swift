//
//  TabMenuView.swift
//  Skrbla
//

import SwiftUI

enum Tabs: Hashable {
    case home
    case history
    case add
    case subscriptions
    case profile
}

private struct OpenAddSheetKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var openAddSheet: (() -> Void)? {
        get { self[OpenAddSheetKey.self] }
        set { self[OpenAddSheetKey.self] = newValue }
    }
}

struct TabMenuView: View {
    @EnvironmentObject private var authState: AuthState
    @EnvironmentObject private var financeStore: FinanceStore
    @State private var selectedTab: Tabs = .home
    @State private var showManualAdd = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Domů", systemImage: "house", value: .home) {
                HomeView()
                    .environment(\.openAddSheet, { showManualAdd = true })
            }

            Tab("Historie", systemImage: "clock", value: .history) {
                HistoryView()
                    .environment(\.openAddSheet, { showManualAdd = true })
            }

            Tab("Přidat", systemImage: "plus", value: .add, role: .search) {
                Color.clear
            }

            Tab("Předplatné", systemImage: "calendar", value: .subscriptions) {
                SubscriptionView()
                    .environment(\.openAddSheet, { showManualAdd = true })
            }

            Tab("Profil", systemImage: "person", value: .profile) {
                NavigationStack {
                    ProfileView()
                }
            }
        }
        .tint(SkrblaTheme.primary)
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .add {
                showManualAdd = true
                selectedTab = oldValue
            }
        }
        .fullScreenCover(isPresented: $showManualAdd) {
            ManualExpenseFlowView(isPresented: $showManualAdd)
                .environmentObject(financeStore)
        }
    }
}

#Preview {
    TabMenuView()
        .environmentObject(AuthState())
}
