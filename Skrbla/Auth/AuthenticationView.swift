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
    @State private var isAuthenticating = false
    @State private var showSuccessAnimation = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Face ID Icon - pouze ikona
                ZStack {
                    // Pulsující kruhy během ověření
                    if isAuthenticating {
                        ForEach(0..<2) { index in
                            Circle()
                                .stroke(
                                    Color.blue.opacity(0.15),
                                    lineWidth: 0.5
                                )
                                .frame(width: 140 + CGFloat(index * 40), height: 140 + CGFloat(index * 40))
                                .scaleEffect(isAnimating ? 1.4 : 0.8)
                                .opacity(isAnimating ? 0.0 : 0.3)
                                .animation(
                                    .easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.4),
                                    value: isAnimating
                                )
                        }
                    }
                    
                    // Icon container s iOS 16+ glass effect
                    ZStack {
                        // Glass effect background - iOS 16+ style
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.2),
                                                Color.white.opacity(0.05)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.3),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                        
                        // Icon
                        Image(systemName: showSuccessAnimation ? "checkmark" : "faceid")
                            .foregroundColor(showSuccessAnimation ? .green : .blue)
                            .font(.system(size: 40, weight: .medium))
                    }
                    .scaleEffect(isAnimating ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                }
                
                Spacer()
            }
        }
        .onAppear {
            isAnimating = true
            // Automaticky spustit ověření okamžitě po zobrazení
            startAuthentication()
        }
        .onReceive(authManager.$isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                showSuccessAnimation = true
                isAuthenticating = false
            }
        }
        .onReceive(authManager.$authenticationError) { error in
            if error != nil {
                // Zkusit znovu po chybě
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    authManager.authenticationError = nil
                    isAuthenticating = false
                    // Zkusit znovu po chybě
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        startAuthentication()
                    }
                }
            }
        }
    }
    
    private func startAuthentication() {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        authManager.authenticateWithBiometrics()
    }
}

#Preview {
    AuthenticationView(authManager: AuthenticationManager())
}


