//
//  SkrblaApp.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

@main
struct SkrblaApp: App {
    @State private var showLaunchScreen = true
    @State private var showAuthentication = false
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var appStateManager = AppStateManager()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main app content - zobrazit pouze pokud je uživatel ověřen
                if authManager.isAuthenticated && !showAuthentication {
                    ContentView()
                        .opacity(showLaunchScreen ? 0 : 1)
                        .animation(.easeIn(duration: 0.3).delay(0.2), value: showLaunchScreen)
                        .environmentObject(authManager)
                        .environmentObject(appStateManager)
                }
                
                // Launch screen - zobrazit pouze při prvním spuštění
                if showLaunchScreen && !showAuthentication && !appStateManager.shouldRequireAuth {
                    LaunchView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showLaunchScreen = false
                                    showAuthentication = true
                                }
                            }
                        }
                }
                
                // Onboarding
                if isFirstLaunch && !showAuthentication && !showLaunchScreen && !appStateManager.shouldRequireAuth {
                    OnboardingView()
                        .transition(.opacity)
                }
                
                // Authentication overlay - zobrazit při prvním spuštění nebo při návratu z pozadí
                if showAuthentication || appStateManager.shouldRequireAuth {
                    AuthenticationView(authManager: authManager)
                        .transition(.opacity)
                        .zIndex(1000)
                }
                
                // Privacy overlay – jen v reálném pozadí (pro App Switcher snapshot)
                if appStateManager.isInBackground {
                    PrivacyScreen()
                        .transition(.opacity)
                        .zIndex(2000)
                }
            }
            .onReceive(appStateManager.$shouldRequireAuth) { shouldRequire in
                if shouldRequire {
                    // Při návratu z pozadí - vždy zobrazit ověření
                    print("🔄 Návrat z pozadí - vyžaduje se ověření")
                    authManager.requireAuthentication()
                    showAuthentication = true
                    showLaunchScreen = false
                }
            }
            .onReceive(authManager.$isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    print("✅ Ověření úspěšné - přesměrovávám")
                    // Pouze 0.5 sekundy success animace a pak přesměrovat
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAuthentication = false
                        }
                        // Resetovat stav pozadí
                        appStateManager.resetBackgroundState()
                    }
                }
            }
        }
    }
}
