//
//  SkrblaApp.swift
//  Skrbla
//

import SwiftUI

private let onboardingCompletedKey = "Skrbla.hasCompletedOnboarding"
private let appearanceModeKey = "settings.appearance.mode"

@main
struct SkrblaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authState = AuthState()
    @StateObject private var sessionUnlock = SessionUnlockState()
    @AppStorage(onboardingCompletedKey) private var hasCompletedOnboarding = false
    @AppStorage(appearanceModeKey) private var appearanceModeRaw: String = "system"
    @State private var showLaunchScreen = true
    @State private var showBiometricVerification = false
    @State private var hasVerifiedBiometricThisSession = false
    @State private var backgroundedAt: Date?
    @Environment(\.scenePhase) private var scenePhase

    private var needsImmediateBiometricOnResume: Bool {
        guard authState.isLoggedIn, scenePhase == .active, let at = backgroundedAt else { return false }
        return Date().timeIntervalSince(at) >= 5
    }

    private var shouldShowBiometricOverlay: Bool {
        guard authState.isLoggedIn else { return false }
        if showBiometricVerification || needsImmediateBiometricOnResume { return true }
        if !showLaunchScreen, hasCompletedOnboarding, !hasVerifiedBiometricThisSession { return true }
        return false
    }

    private var preferredColorScheme: ColorScheme? {
        switch appearanceModeRaw {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    LaunchView(onFinish: { showLaunchScreen = false })
                } else if !hasCompletedOnboarding {
                    OnboardingView(onFinish: {
                        hasCompletedOnboarding = true
                        appDelegate.preparePushNotifications()
                    })
                } else if authState.isLoggedIn {
                    ContentView()
                } else {
                    LoginView()
                }

                if scenePhase == .background {
                    PrivacyScreen()
                        .ignoresSafeArea()
                        .zIndex(2)
                }

                if shouldShowBiometricOverlay {
                    BiometricVerificationView(onSuccess: {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            showBiometricVerification = false
                            hasVerifiedBiometricThisSession = true
                            sessionUnlock.unlock()
                        }
                    })
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(3)
                }
            }
            .preferredColorScheme(preferredColorScheme)
            .environmentObject(authState)
            .environmentObject(appDelegate)
            .environmentObject(sessionUnlock)
            .environmentObject(FinanceStore.shared)
            .environment(\.sessionUnlocked, sessionUnlock.isUnlocked)
            .onChange(of: authState.isLoggedIn) { _, isLoggedIn in
                if !isLoggedIn {
                    sessionUnlock.lock()
                    hasVerifiedBiometricThisSession = false
                    LiveActivityManager.shared.endActivity()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .background:
                    backgroundedAt = Date()
                case .inactive:
                    if authState.isLoggedIn, let at = backgroundedAt, Date().timeIntervalSince(at) >= 5 {
                        showBiometricVerification = true
                        sessionUnlock.lock()
                    }
                case .active:
                    if authState.isLoggedIn, let at = backgroundedAt, Date().timeIntervalSince(at) >= 5 {
                        showBiometricVerification = true
                        sessionUnlock.lock()
                    }
                    backgroundedAt = nil
                default:
                    break
                }
            }
        }
    }
}
