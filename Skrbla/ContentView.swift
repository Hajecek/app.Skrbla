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
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainContentView(tabs: TabItem.defaultTabs) { selectedIndex in
                    switch selectedIndex {
                    case 0:
                        HomeView()
                    case 1:
                        AddView()
                    case 2:
                        HistoryView()
                    case 3:
                        ProfileView()
                    default:
                        HomeView()
                    }
                }
            } else {
                // Zobrazit loading nebo prázdnou obrazovku během ověření
                Color.black
                    .ignoresSafeArea()
            }
        }
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
