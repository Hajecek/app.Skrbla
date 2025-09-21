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
    @AppStorage("wasLoggedOut") private var wasLoggedOut: Bool = false
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
                
                // 1.5) Explicitní přesměrování na LoginView po logoutu (trvalé, dokud se nepřihlásí)
                if (appStateManager.forceLoginScreen || wasLoggedOut) && !authManager.isAuthenticated {
                    LoginView(authManager: authManager)
                        .transition(.opacity)
                        .environmentObject(appStateManager)
                }
                
                // 2) LoginView – pouze při prvním spuštění po dokončení onboardingu
                if isFirstLaunch &&
                    didFinishOnboarding &&
                    !authManager.isAuthenticated &&
                    !showLaunchScreen &&
                    !showAuthentication &&
                    !appStateManager.shouldRequireAuth &&
                    !appStateManager.forceLoginScreen &&
                    !wasLoggedOut {
                    LoginView(authManager: authManager)
                        .transition(.opacity)
                        .environmentObject(appStateManager)
                }
                
                // 3) Launch screen – VŽDY při startu, dokud je showLaunchScreen == true
                // Odebrali jsme podmínku !wasLoggedOut, aby se Launch ukázal i po odhlášení.
                if showLaunchScreen &&
                    !showAuthentication &&
                    !appStateManager.shouldRequireAuth &&
                    !appStateManager.forceLoginScreen {
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
                                        if !isFirstLaunch && !authManager.isAuthenticated && !wasLoggedOut {
                                            // Pokud jsme odhlášeni (wasLoggedOut), nechceme rovnou biometriku,
                                            // protože zobrazujeme LoginView. Proto přidán !wasLoggedOut.
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
                    !appStateManager.shouldRequireAuth &&
                    !appStateManager.forceLoginScreen &&
                    !wasLoggedOut {
                    OnboardingView {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            didFinishOnboarding = true
                        }
                    }
                    .transition(.opacity)
                }
                
                // 5) Biometrická autentizace – jen pokud nejsme v režimu „po logoutu drž LoginView“
                if (showAuthentication ||
                    appStateManager.shouldRequireAuth ||
                    (!isFirstLaunch && !authManager.isAuthenticated && !showLaunchScreen)) &&
                    !appStateManager.forceLoginScreen &&
                    !wasLoggedOut {
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
                // Pokud jsme po odhlášení (wasLoggedOut == true), nevyžaduj biometriku
                if shouldRequire && !wasLoggedOut {
                    print("🔄 Návrat z pozadí - vyžaduje se ověření")
                    authManager.requireAuthentication()
                    showAuthentication = true
                    showLaunchScreen = false
                }
            }
            .onReceive(authManager.$isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    print("✅ Ověření/přihlášení úspěšné - přesměrovávám")
                    // Po úspěšném přihlášení vypnout režim „po logoutu“
                    wasLoggedOut = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAuthentication = false
                        }
                        appStateManager.resetBackgroundState()
                        appStateManager.forceLoginScreen = false
                    }
                }
            }
            // DŮLEŽITÉ: odstraňujeme hacky, které vypínaly launch při wasLoggedOut,
            // aby se LaunchView ukázalo při každém startu:
            // - Žádné .onAppear { if wasLoggedOut { showLaunchScreen = false } }
            // - Žádné .onChange(of: wasLoggedOut) { ... vypnutí launch ... }
        }
    }
}
