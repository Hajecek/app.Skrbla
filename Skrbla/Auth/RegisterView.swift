//
//  RegisterView.swift
//  Skrbla
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var authState: AuthState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var appeared = false
    @FocusState private var focusedField: AuthFieldFocus?

    private var canSubmit: Bool {
        !isLoading
            && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && password.count >= 4
    }

    var body: some View {
        AuthScreenChrome(appeared: appeared) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(colorScheme == .dark ? .white : SkrblaTheme.slate)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(colorScheme == .dark ? Color.white.opacity(0.08) : SkrblaTheme.slate.opacity(0.06))
                            )
                    }
                    Spacer()
                }
                .padding(.bottom, 18)

                Text("Nový účet")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(colorScheme == .dark ? .white : SkrblaTheme.slate)

                Text("Zatím jen lokálně v zařízení — backend přijde později.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.55) : SkrblaTheme.slate.opacity(0.55))
                    .padding(.top, 6)
                    .padding(.bottom, 26)

                VStack(spacing: 22) {
                    AuthTextField(
                        title: "Jméno",
                        systemImage: "person",
                        text: $name,
                        focus: .name,
                        focusedField: $focusedField,
                        contentType: .name,
                        submitLabel: .next
                    ) {
                        focusedField = .email
                    }

                    AuthTextField(
                        title: "E-mail",
                        systemImage: "envelope",
                        text: $email,
                        focus: .email,
                        focusedField: $focusedField,
                        contentType: .emailAddress,
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
                        contentType: .newPassword,
                        submitLabel: .go
                    ) {
                        if canSubmit { register() }
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 0.78, green: 0.2, blue: 0.24))
                        .padding(.top, 16)
                }

                AuthPrimaryButton(
                    title: isLoading ? "Vytvářím…" : "Vytvořit účet",
                    isLoading: isLoading,
                    isEnabled: canSubmit
                ) {
                    focusedField = nil
                    register()
                }
                .padding(.top, 28)
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

    private func register() {
        isLoading = true
        errorMessage = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            let ok = authState.logIn(email: email, password: password, name: name)
            isLoading = false
            if ok {
                dismiss()
            } else {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    errorMessage = "Kontrola údajů selhala. Zkus to znovu."
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
    .environmentObject(AuthState())
}
