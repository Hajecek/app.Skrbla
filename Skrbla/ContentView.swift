//
//  ContentView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var appStateManager: AppStateManager
    // Injectujeme FinanceStore do celé hierarchie
    @StateObject private var financeStore = FinanceStore()
    
    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                // Native iOS 26 TabView s mini playerem nad tab barem
                iOS26TabContainer()
            } else {
                // Fallback: vlastní kapslový bar
                MainContentView(tabs: TabItem.defaultTabs) { selectedIndex, onSelectTab in
                    switch selectedIndex {
                    case 0:
                        HomeView(onOpenHistory: { onSelectTab(2) })
                    case 1:
                        HistoryView()
                    case 2:
                        SubscriptionView()
                    case 3:
                        ProfileView()
                    default:
                        HomeView(onOpenHistory: { onSelectTab(2) })
                    }
                }
            }
        }
        .environmentObject(financeStore)
        .onReceive(appStateManager.$shouldRequireAuth) { shouldRequire in
            if shouldRequire {
                authManager.requireAuthentication()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
        .environmentObject(AppStateManager())
}

