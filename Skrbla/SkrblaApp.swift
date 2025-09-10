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
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var appStateManager = AppStateManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main app content
                ContentView()
                    .opacity(showLaunchScreen ? 0 : 1)
                    .animation(.easeIn(duration: 0.3).delay(0.2), value: showLaunchScreen)
                    .environmentObject(authManager)
                    .environmentObject(appStateManager)
                
                // Launch screen
                if showLaunchScreen {
                    LaunchView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showLaunchScreen = false
                                }
                            }
                        }
                }
                
                // Onboarding
                if isFirstLaunch {
                    OnboardingView()
                        .transition(.opacity)
                }
                
                // Authentication overlay
                if authManager.showAuthentication {
                    AuthenticationView(authManager: authManager)
                        .transition(.opacity)
                        .zIndex(1000)
                }
            }
            .onReceive(appStateManager.$shouldRequireAuth) { shouldRequire in
                if shouldRequire && !authManager.isAuthenticated {
                    authManager.requireAuthentication()
                }
            }
            .onAppear {
                // Při spuštění aplikace ověřit, zda je potřeba autentifikace
                if appStateManager.shouldRequireAuthentication() {
                    authManager.requireAuthentication()
                }
            }
        }
    }
}
