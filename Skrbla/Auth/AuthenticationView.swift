//
//  AuthenticationView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI
import LocalAuthentication

struct AuthenticationView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo/Icon
                VStack(spacing: 20) {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: getBiometricIcon())
                                .foregroundColor(.white)
                                .font(.system(size: 50))
                        )
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    
                    VStack(spacing: 8) {
                        Text("Ověření identity")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Použijte \(authManager.getBiometricTypeString()) pro pokračování")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Authentication Buttons
                VStack(spacing: 16) {
                    // Primary authentication button
                    Button(action: {
                        authManager.authenticateWithBiometrics()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: getBiometricIcon())
                                .font(.system(size: 20))
                            
                            Text("Ověřit pomocí \(authManager.getBiometricTypeString())")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Alternative authentication button
                    Button(action: {
                        authManager.authenticateWithPasscode()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 20))
                            
                            Text("Ověřit pomocí kódu")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 40)
                
                // Error message
                if let error = authManager.authenticationError {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
        }
        .onAppear {
            isAnimating = true
            // Automaticky spustit biometrické ověření při zobrazení
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                authManager.authenticateWithBiometrics()
            }
        }
    }
    
    private func getBiometricIcon() -> String {
        switch authManager.getBiometricType() {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        default:
            return "lock.shield"
        }
    }
}

#Preview {
    AuthenticationView(authManager: AuthenticationManager())
}
