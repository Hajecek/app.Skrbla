//
//  AppStateManager.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import Foundation
import SwiftUI

// MARK: - App State Manager
class AppStateManager: ObservableObject {
    @Published var isInBackground = false
    @Published var backgroundTime: Date?
    @Published var shouldRequireAuth = false
    
    private let backgroundThreshold: TimeInterval = 5.0 // 5 sekund
    private var backgroundTimer: Timer?
    
    init() {
        setupNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notification Setup
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    // MARK: - Background Handling
    @objc private func appDidEnterBackground() {
        print("📱 Aplikace jde do pozadí")
        isInBackground = true
        backgroundTime = Date()
        
        // Spustit timer pro sledování času v pozadí
        backgroundTimer = Timer.scheduledTimer(withTimeInterval: backgroundThreshold, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                print("⏰ 5 sekund v pozadí - nastavuji shouldRequireAuth = true")
                self?.shouldRequireAuth = true
            }
        }
    }
    
    @objc private func appWillEnterForeground() {
        print("📱 Aplikace se vrací z pozadí")
        isInBackground = false
        backgroundTimer?.invalidate()
        backgroundTimer = nil
        
        // Zkontrolovat, zda je potřeba ověření
        if shouldRequireAuth {
            print("🔐 Potřebuje se ověření - shouldRequireAuth = true")
        } else {
            print("✅ Není potřeba ověření - resetuji stav")
            backgroundTime = nil
        }
    }
    
    // MARK: - Authentication Check
    func shouldRequireAuthentication() -> Bool {
        guard let backgroundTime = backgroundTime else { return false }
        let timeInBackground = Date().timeIntervalSince(backgroundTime)
        return timeInBackground >= backgroundThreshold
    }
    
    // MARK: - Reset
    func resetBackgroundState() {
        print("🔄 Resetuji stav pozadí")
        backgroundTime = nil
        shouldRequireAuth = false
        backgroundTimer?.invalidate()
        backgroundTimer = nil
    }
}