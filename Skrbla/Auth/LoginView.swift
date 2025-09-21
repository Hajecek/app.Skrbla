//
//  LoginView.swift
//  Skrbla
//
//  Created by Michal Hájek on 21.09.2025.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var authManager: AuthenticationManager
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer(minLength: 20)
                    .frame(maxHeight: .infinity)
                
                VStack(spacing: 20) {
                    // Logo / Branding
                    Image(colorScheme == .dark ? "LogoDark" : "Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 88)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.bottom, 6)
                    
                    Text("Přihlášení")
                        .font(.largeTitle.bold())
                    
                    // Form
                    VStack(spacing: 14) {
                        TextField("E‑mail", text: $email)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                        
                        SecureField("Heslo", text: $password)
                            .textContentType(.password)
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        login()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            }
                            Text("Přihlásit se")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20)
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .opacity(isLoading || email.isEmpty || password.isEmpty ? 0.7 : 1)
                    
                    // Linky
                    VStack(spacing: 8) {
                        Button("Zapomenuté heslo?") {
                            // TODO: reset hesla
                        }
                        .font(.footnote)
                        
                        Button("Vytvořit nový účet") {
                            // TODO: registrace
                        }
                        .font(.footnote)
                    }
                    .padding(.bottom, 4)
                }
                
                Spacer(minLength: 20)
                    .frame(maxHeight: .infinity)
            }
        }
    }
    
    private func login() {
        guard !email.isEmpty, !password.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        // Zde by normálně proběhl síťový request. Pro demo uděláme krátké zpoždění.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // Simulace úspěchu – nahraď vlastní validací/API voláním
            let success = true
            
            if success {
                authManager.isAuthenticated = true
                isFirstLaunch = false
            } else {
                errorMessage = "Neplatné přihlašovací údaje. Zkus to znovu."
            }
            isLoading = false
        }
    }
}

#Preview {
    LoginView(authManager: AuthenticationManager())
}
