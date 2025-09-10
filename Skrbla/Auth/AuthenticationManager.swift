//
//  AuthenticationManager.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import Foundation
import LocalAuthentication
import SwiftUI

// MARK: - Authentication Manager
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showAuthentication = false
    @Published var authenticationError: String?
    
    private let context = LAContext()
    private let reason = "Ověřte svou identitu pro přístup k aplikaci"
    
    init() {
        // Zkontrolujeme dostupnost biometrického ověření při inicializaci
        checkBiometricAvailability()
    }
    
    // MARK: - Biometric Availability Check
    func checkBiometricAvailability() {
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if !canEvaluate {
            // Pokud biometrické ověření není dostupné, zkusíme ověření pomocí kódu
            let canEvaluatePasscode = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
            if !canEvaluatePasscode {
                authenticationError = "Ověření identity není dostupné na tomto zařízení"
            }
        }
    }
    
    // MARK: - Authentication Methods
    func authenticateWithBiometrics() {
        print("🔐 Spouštím biometrické ověření")
        
        // Vytvořit nový kontext pro každé ověření
        let newContext = LAContext()
        
        // Zkontrolovat dostupnost biometrického ověření
        var error: NSError?
        let canEvaluateBiometrics = newContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        let policy: LAPolicy = canEvaluateBiometrics ? 
            .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication
        
        newContext.evaluatePolicy(policy, localizedReason: reason) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    print("✅ Ověření úspěšné")
                    self?.isAuthenticated = true
                    self?.showAuthentication = false
                    self?.authenticationError = nil
                } else {
                    print("❌ Ověření se nezdařilo: \(error?.localizedDescription ?? "Neznámá chyba")")
                    self?.authenticationError = error?.localizedDescription ?? "Ověření se nezdařilo"
                }
            }
        }
    }
    
    // MARK: - Authentication State Management
    func requireAuthentication() {
        print(" Vyžaduji ověření - resetuji stav")
        isAuthenticated = false
        showAuthentication = true
        authenticationError = nil
    }
    
    func logout() {
        print("🚪 Odhlašuji uživatele")
        isAuthenticated = false
        showAuthentication = false
        authenticationError = nil
    }
    
    // MARK: - Biometric Type Detection
    func getBiometricType() -> LABiometryType {
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            return context.biometryType
        }
        return .none
    }
    
    func getBiometricTypeString() -> String {
        switch getBiometricType() {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        default:
            return "Kód"
        }
    }
}
