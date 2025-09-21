//
//  ProfileView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

// MARK: - Profile View (iOS 26-first card layout)
struct ProfileView: View {
    @Environment(\.colorScheme) private var scheme
    
    // Mock data – napojte na Store/Model
    private let displayName = "Michal Hájek"
    private let email = "michal@skrbla.com"
    private let itemsCount = 24
    private let thisMonth = 8
    private let total = 156
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Sticky-like header card
                    ProfileHeroHeader(name: displayName, email: email)
                        .padding(.top, 12)
                        .padding(.horizontal, 16)
                    
                    // Stats as a single card with 3 columns (more cohesive)
                    StatsCard(items: itemsCount, month: thisMonth, total: total)
                        .padding(.horizontal, 16)
                    
                    // Live activity card
                    LiveActivityCard()
                        .padding(.horizontal, 16)
                    
                    // Settings card (nativní řádky uvnitř karty)
                    SettingsCard()
                        .padding(.horizontal, 16)
                    
                    // Logout (plně červené) + Delete account (obrysové destruktivní)
                    RedFilledDestructiveButton(
                        title: "Odhlásit se",
                        systemImage: "rectangle.portrait.and.arrow.right"
                    ) {
                        // TODO: Logout action
                    }
                    .padding(.horizontal, 16)
                    
                    OutlineDestructiveButton(
                        title: "Vymazat účet",
                        systemImage: "trash"
                    ) {
                        // TODO: Delete account action (potvrzení + nevratná akce)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .background(.background)
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            // TODO: Edit profile
                        } label: {
                            Label("Upravit profil", systemImage: "pencil")
                        }
                        Button {
                            // TODO: Share profile
                        } label: {
                            Label("Sdílet", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Možnosti")
                }
            }
        }
    }
}

// MARK: - Hero Header
private struct ProfileHeroHeader: View {
    var name: String
    var email: String
    
    var body: some View {
        HStack(spacing: 16) {
            Avatar(size: 72, symbolSize: 30)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.title2.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                HStack(spacing: 8) {
                    Label("Účet ověřen", systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .labelStyle(.titleAndIcon)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.green, .secondary)
                }
            }
            
            Spacer()
            
            Button {
                // TODO: Open QR / profile code
            } label: {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 18, weight: .semibold))
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Zobrazit kód")
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.6)
                )
        }
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct Avatar: View {
    var size: CGFloat = 64
    var symbolSize: CGFloat = 26
    
    var body: some View {
        ZStack {
            if #available(iOS 26.0, *) {
                Circle()
                    .fill(.clear)
                    .glassEffect(.regular, in: Circle())
                    .overlay(
                        Circle()
                            .fill(Color.accentColor.opacity(0.22))
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(Color.accentColor.opacity(0.35), lineWidth: 1)
                    )
            } else {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .fill(Color.accentColor.opacity(0.18))
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(Color.accentColor.opacity(0.30), lineWidth: 1)
                    )
            }
            Image(systemName: "person.fill")
                .font(.system(size: symbolSize, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 1)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

// MARK: - Stats Card
private struct StatsCard: View {
    var items: Int
    var month: Int
    var total: Int
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistiky")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 12)
            
            LazyVGrid(columns: columns, spacing: 12) {
                StatPill(title: "Položky", value: "\(items)", color: .blue, symbol: "tray.full.fill")
                StatPill(title: "Tento měsíc", value: "\(month)", color: .green, symbol: "calendar")
                StatPill(title: "Celkem", value: "\(total)", color: .orange, symbol: "sum")
            }
            .padding(12)
            .padding(.top, -4)
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.6)
                )
        )
    }
}

private struct StatPill: View {
    let title: String
    let value: String
    let color: Color
    let symbol: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(color.opacity(0.18))
                    Image(systemName: symbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(color)
                }
                .frame(width: 28, height: 28)
                Spacer()
            }
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(color)
                .lineLimit(1)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.6)
                )
        )
    }
}

// MARK: - Live Activity Card
private struct LiveActivityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Live Aktivita", systemImage: "waveform.path.ecg.rectangle")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            VStack(spacing: 10) {
                Button {
                    LiveActivityManager.shared.startActivity()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    Label("Spustit", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                HStack(spacing: 12) {
                    Button {
                        LiveActivityManager.shared.updateActivity(
                            currentAmount: 15000,
                            lastTransaction: "Platba za služby",
                            amount: 1200,
                            isPositive: false,
                            category: "Služby"
                        )
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Label("Aktualizovat", systemImage: "arrow.triangle.2.circlepath")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(role: .destructive) {
                        LiveActivityManager.shared.endActivity()
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        Label("Ukončit", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.6)
                )
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Live Aktivita")
    }
}

// MARK: - Settings Card
private struct SettingsCard: View {
    var body: some View {
        VStack(spacing: 0) {
            SettingsRow(title: "Upravit profil", systemImage: "person.circle") {
                // TODO
            }
            Divider().opacity(0.08)
            SettingsRow(title: "Notifikace", systemImage: "bell") {
                // TODO
            }
            Divider().opacity(0.08)
            SettingsRow(title: "Soukromí", systemImage: "lock") {
                // TODO
            }
            Divider().opacity(0.08)
            SettingsRow(title: "Nápověda", systemImage: "questionmark.circle") {
                // TODO
            }
            Divider().opacity(0.08)
            SettingsRow(title: "Nastavení", systemImage: "gear") {
                // TODO
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.6)
                )
        )
    }
}

private struct SettingsRow: View {
    var title: String
    var systemImage: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.accentColor.opacity(0.16))
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.tint)
                }
                .frame(width: 34, height: 34)
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Red Filled Destructive Button (Logout)
private struct RedFilledDestructiveButton: View {
    var title: String
    var systemImage: String
    var action: () -> Void
    
    var body: some View {
        Button(role: .destructive, action: action) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .semibold))
                Text(title)
                    .font(.body.weight(.semibold))
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.red)
            )
        }
        .buttonStyle(.plain)
        .tint(.white)
        .accessibilityHint("Odhlásí vás z aplikace")
    }
}

// MARK: - Outline Destructive Button (Delete Account)
private struct OutlineDestructiveButton: View {
    var title: String
    var systemImage: String
    var action: () -> Void
    
    var body: some View {
        Button(role: .destructive, action: action) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .semibold))
                Text(title)
                    .font(.body.weight(.semibold))
                Spacer()
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.red.opacity(0.6), lineWidth: 1.0)
                    )
            )
        }
        .buttonStyle(.plain)
        .tint(.red)
        .accessibilityHint("Trvale vymaže váš účet a všechna data")
    }
}

// MARK: - Legacy (ponecháno pro kompatibilitu s referencemi)
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.1))
                )
        )
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(color)
                            .font(.system(size: 18))
                    )
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.4))
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .preferredColorScheme(.dark)
}
