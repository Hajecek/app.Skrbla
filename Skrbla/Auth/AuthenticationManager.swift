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
        let policy: LAPolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? 
            .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication
        
        context.evaluatePolicy(policy, localizedReason: reason) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthenticated = true
                    self?.showAuthentication = false
                    self?.authenticationError = nil
                } else {
                    self?.authenticationError = error?.localizedDescription ?? "Ověření se nezdařilo"
                }
            }
        }
    }
    
    func authenticateWithPasscode() {
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthenticated = true
                    self?.showAuthentication = false
                    self?.authenticationError = nil
                } else {
                    self?.authenticationError = error?.localizedDescription ?? "Ověření se nezdařilo"
                }
            }
        }
    }
    
    // MARK: - Authentication State Management
    func requireAuthentication() {
        isAuthenticated = false
        showAuthentication = true
    }
    
    func logout() {
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
