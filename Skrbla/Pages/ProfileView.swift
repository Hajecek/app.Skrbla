//
//  ProfileView.swift
//  Skrbla
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authState: AuthState
    @EnvironmentObject private var financeStore: FinanceStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var isShowingEdit = false
    @State private var showLogoutConfirm = false
    @State private var appeared = false

    private let avatarSize: CGFloat = 108
    private let avatarOverlap: CGFloat = 54

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroBand
                contentSheet
            }
        }
        .background(pageBackground)
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.body.weight(.medium))
                }
                .accessibilityLabel("Nastavení")
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $isShowingEdit) {
            NavigationStack {
                EditProfileView()
            }
        }
        .alert("Opravdu se chcete odhlásit?", isPresented: $showLogoutConfirm) {
            Button("Zrušit", role: .cancel) {}
            Button("Odhlásit", role: .destructive) {
                authState.logOut()
            }
        } message: {
            Text("Budete odhlášeni z vašeho účtu. Lokální data výdajů zůstanou v zařízení.")
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.86)) {
                appeared = true
            }
        }
    }

    private var heroBand: some View {
        ZStack(alignment: .bottom) {
            heroGradient
                .frame(height: 248)
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 180, height: 180)
                        .blur(radius: 2)
                        .offset(x: 50, y: -30)
                }
                .overlay(alignment: .topLeading) {
                    Circle()
                        .fill(SkrblaTheme.accent.opacity(0.18))
                        .frame(width: 120, height: 120)
                        .blur(radius: 18)
                        .offset(x: -40, y: 40)
                }

            VStack(spacing: 10) {
                Text("OSOBNÍ FINANCE")
                    .font(.caption.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(.white.opacity(0.78))

                Text(authState.currentUser?.displayName ?? "Uživatel")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .padding(.horizontal, 28)

                if let email = authState.currentUser?.email {
                    Text(email)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.78))
                }

                Spacer(minLength: avatarOverlap + 8)
            }
            .padding(.top, 88)
            .frame(maxWidth: .infinity)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
        }
        .overlay(alignment: .bottom) {
            UserAvatarView(user: authState.currentUser, size: avatarSize)
                .overlay {
                    Circle()
                        .stroke(Color(uiColor: .systemBackground), lineWidth: 5)
                }
                .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 8)
                .scaleEffect(appeared ? 1 : 0.82)
                .opacity(appeared ? 1 : 0)
                .offset(y: avatarOverlap)
                .contextMenu {
                    Button {
                        isShowingEdit = true
                    } label: {
                        Label("Upravit profil", systemImage: "pencil")
                    }
                }
        }
        .zIndex(1)
    }

    private var heroGradient: some View {
        LinearGradient(
            colors: [
                SkrblaTheme.slate,
                SkrblaTheme.primaryDeep.opacity(0.95),
                SkrblaTheme.secondary
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var contentSheet: some View {
        VStack(alignment: .leading, spacing: 28) {
            identityMeta
                .padding(.top, avatarOverlap + 18)

            factsBlock
            actionsBlock
            logoutBlock
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 36)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: 28,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 28,
                style: .continuous
            )
            .fill(Color(uiColor: .systemBackground))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.35 : 0.08), radius: 20, y: -4)
            .ignoresSafeArea(edges: .bottom)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 28)
    }

    private var identityMeta: some View {
        HStack(spacing: 12) {
            Text("Lokální účet")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(uiColor: .secondarySystemBackground), in: Capsule())
            Spacer(minLength: 0)
        }
    }

    private var factsBlock: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionLabel("Přehled")
            VStack(spacing: 0) {
                factRow(title: "Výdaje celkem", value: "\(financeStore.expenses.count)")
                thinRule
                factRow(title: "Tento měsíc", value: SkrblaTheme.formatCurrency(financeStore.thisMonthSpent))
                thinRule
                factRow(title: "Předplatná", value: "\(financeStore.activeSubscriptions.count)")
            }
        }
    }

    private var actionsBlock: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionLabel("Možnosti")
            VStack(spacing: 10) {
                NavigationLink {
                    SettingsView()
                } label: {
                    optionLabel(
                        title: "Nastavení",
                        detail: "Vzhled, rozpočet, data",
                        symbol: "slider.horizontal.3"
                    )
                }
                .buttonStyle(.plain)

                Button {
                    isShowingEdit = true
                } label: {
                    optionLabel(
                        title: "Upravit profil",
                        detail: "Jméno a e-mail",
                        symbol: "person.text.rectangle"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var logoutBlock: some View {
        Button {
            showLogoutConfirm = true
        } label: {
            Text("Odhlásit se")
                .font(.body.weight(.semibold))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    private var pageBackground: some View {
        ZStack {
            heroGradient.ignoresSafeArea()
            Color(uiColor: .systemBackground)
                .ignoresSafeArea(edges: .bottom)
                .padding(.top, 200)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .tracking(0.8)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }

    private func factRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 128, alignment: .leading)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 12)
    }

    private var thinRule: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.06))
            .frame(height: 1)
    }

    private func optionLabel(title: String, detail: String, symbol: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(SkrblaTheme.primary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct EditProfileView: View {
    @EnvironmentObject private var authState: AuthState
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""

    var body: some View {
        Form {
            Section {
                TextField("Jméno", text: $name)
                TextField("E-mail", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
            } footer: {
                Text("Zatím se ukládá jen lokálně v zařízení.")
            }
        }
        .navigationTitle("Upravit profil")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Zrušit") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Hotovo") {
                    authState.updateProfile(name: name, email: email)
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            name = authState.currentUser?.name ?? ""
            email = authState.currentUser?.email ?? ""
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environmentObject(AuthState())
    .environmentObject(FinanceStore.shared)
}
