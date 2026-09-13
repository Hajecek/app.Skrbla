//
//  LoginView.swift
//  Skrbla
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authState: AuthState
    @Environment(\.colorScheme) private var colorScheme

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var appeared = false
    @FocusState private var focusedField: AuthFieldFocus?

    private var canSubmit: Bool {
        !isLoading
            && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && password.count >= 4
    }

    var body: some View {
        NavigationStack {
            AuthScreenChrome(appeared: appeared) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Vítej zpět")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(colorScheme == .dark ? .white : SkrblaTheme.slate)

                    Text("Přihlas se a pokračuj v přehledu výdajů.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.55) : SkrblaTheme.slate.opacity(0.55))
                        .padding(.top, 6)
                        .padding(.bottom, 28)

                    VStack(spacing: 22) {
                        AuthTextField(
                            title: "E-mail",
                            systemImage: "envelope",
                            text: $email,
                            focus: .email,
                            focusedField: $focusedField,
                            contentType: .username,
                            keyboard: .emailAddress,
                            submitLabel: .next
                        ) {
                            focusedField = .password
                        }

                        AuthTextField(
                            title: "Heslo",
                            systemImage: "lock",
                            isSecure: true,
                            text: $password,
                            focus: .password,
                            focusedField: $focusedField,
                            contentType: .password,
                            submitLabel: .go
                        ) {
                            if canSubmit { performLogin() }
                        }
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(red: 0.78, green: 0.2, blue: 0.24))
                            .padding(.top, 16)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    AuthPrimaryButton(
                        title: isLoading ? "Přihlašuji…" : "Přihlásit se",
                        isLoading: isLoading,
                        isEnabled: canSubmit
                    ) {
                        focusedField = nil
                        performLogin()
                    }
                    .padding(.top, 28)

                    VStack(spacing: 16) {
                        NavigationLink {
                            RegisterView()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Nemáš účet?")
                                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.55) : SkrblaTheme.slate.opacity(0.55))
                                Text("Vytvořit")
                                    .foregroundStyle(SkrblaTheme.primaryDeep)
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                        }

                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            authState.continueAsGuest()
                        } label: {
                            Text("Pokračovat bez přihlášení")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(colorScheme == .dark ? SkrblaTheme.primary : SkrblaTheme.primaryDeep)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 22)
                    .padding(.bottom, 18)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.spring(response: 0.68, dampingFraction: 0.84)) {
                    appeared = true
                }
            }
        }
    }

    private func performLogin() {
        isLoading = true
        errorMessage = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            let ok = authState.logIn(email: email, password: password)
            isLoading = false
            if !ok {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    errorMessage = "Zadej e-mail a heslo (min. 4 znaky). Data jsou zatím jen lokální."
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthState())
}
