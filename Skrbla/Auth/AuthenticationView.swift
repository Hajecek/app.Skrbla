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
                
                // Face ID Logo s animací
                VStack(spacing: 0) {
                    ZStack {
                        // Pulsující kruhy během ověření
                        if isAuthenticating {
                            ForEach(0..<3) { index in
                                Circle()
                                    .stroke(
                                        Color.blue.opacity(0.3),
                                        lineWidth: 2
                                    )
                                    .frame(width: 200 + CGFloat(index * 40), height: 200 + CGFloat(index * 40))
                                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                                    .opacity(isAnimating ? 0.1 : 0.6)
                                    .animation(
                                        .easeInOut(duration: 2.0 + Double(index) * 0.5)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.3),
                                        value: isAnimating
                                    )
                            }
                        }
                        
                        // Hlavní Face ID ikona - bez pozadí
                        Image(systemName: showSuccessAnimation ? "checkmark" : "faceid")
                            .foregroundColor(showSuccessAnimation ? .green : .blue)
                            .font(.system(size: 80))
                            .scaleEffect(isAnimating ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            isAnimating = true
            // Automaticky spustit ověření po zobrazení
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                startAuthentication()
            }
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
        isAuthenticating = true
        authManager.authenticateWithBiometrics()
    }
}

#Preview {
    AuthenticationView(authManager: AuthenticationManager())
}

