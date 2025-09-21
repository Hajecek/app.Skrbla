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
    @State private var didFinishOnboarding = false
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var appStateManager = AppStateManager()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // 1) Hlavní obsah – jen pokud je ověřen a není aktivní autentizační overlay
                if authManager.isAuthenticated && !showAuthentication {
                    ContentView()
                        .opacity(showLaunchScreen ? 0 : 1)
                        .animation(.easeIn(duration: 0.3).delay(0.2), value: showLaunchScreen)
                        .environmentObject(authManager)
                        .environmentObject(appStateManager)
                }
                
                // 2) LoginView – pouze při prvním spuštění po dokončení onboardingu
                if isFirstLaunch &&
                    didFinishOnboarding &&
                    !authManager.isAuthenticated &&
                    !showLaunchScreen &&
                    !showAuthentication &&
                    !appStateManager.shouldRequireAuth {
                    LoginView(authManager: authManager)
                        .transition(.opacity)
                        .environmentObject(appStateManager)
                }
                
                // 3) Launch screen – krátce při startu
                if showLaunchScreen && !showAuthentication && !appStateManager.shouldRequireAuth {
                    LaunchView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showLaunchScreen = false
                                    // Po launchi: pokud je vyžadováno ověření z pozadí, zobraz auth overlay
                                    if appStateManager.shouldRequireAuth {
                                        showAuthentication = true
                                    } else {
                                        // Pokud už to není první spuštění a nejsme ověřeni, rovnou zobraz biometriku
                                        if !isFirstLaunch && !authManager.isAuthenticated {
                                            showAuthentication = true
                                        }
                                    }
                                }
                            }
                        }
                }
                
                // 4) Onboarding – jen při prvním spuštění, po launchi, dokud není dokončen
                if isFirstLaunch &&
                    !didFinishOnboarding &&
                    !showAuthentication &&
                    !showLaunchScreen &&
                    !appStateManager.shouldRequireAuth {
                    OnboardingView {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            didFinishOnboarding = true
                        }
                    }
                    .transition(.opacity)
                }
                
                // 5) Biometrická autentizace – při návratu z pozadí, explicitně vyžádaná,
                // a také při startu po prvním spuštění, pokud nejsme ověřeni.
                if showAuthentication ||
                    appStateManager.shouldRequireAuth ||
                    (!isFirstLaunch && !authManager.isAuthenticated && !showLaunchScreen) {
                    AuthenticationView(authManager: authManager)
                        .transition(.opacity)
                        .zIndex(1000)
                }
                
                // 6) Privacy overlay – pro skutečné pozadí (App Switcher snapshot)
                if appStateManager.isInBackground {
                    PrivacyScreen()
                        .transition(.opacity)
                        .zIndex(2000)
                }
            }
            .onReceive(appStateManager.$shouldRequireAuth) { shouldRequire in
                if shouldRequire {
                    print("🔄 Návrat z pozadí - vyžaduje se ověření")
                    authManager.requireAuthentication()
                    showAuthentication = true
                    showLaunchScreen = false
                }
            }
            .onReceive(authManager.$isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    print("✅ Ověření úspěšné - přesměrovávám")
                    // Po úspěšném přihlášení v LoginView se nastaví isFirstLaunch = false (v LoginView),
                    // čímž se při dalším spuštění vynechá Onboarding i Login a zobrazí se biometrika.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAuthentication = false
                        }
                        appStateManager.resetBackgroundState()
                    }
                }
            }
        }
    }
}
