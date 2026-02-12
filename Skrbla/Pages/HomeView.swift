//
//  HomeView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

// MARK: - Home View s horním pruhem
struct HomeView: View {
    var onOpenHistory: () -> Void = {}
    var onOpenProfile: () -> Void = {}
    var onOpenCards: () -> Void = {}
    var onSearch: () -> Void = {}
    
    private let horizontalPadding: CGFloat = 16
    private let circleSize: CGFloat = 44
    private let searchHeight: CGFloat = 48
    private let iconSize: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Neutrální tmavé pozadí, aby ladilo se zbytkem aplikace
            Color.black
                .ignoresSafeArea()
            
            // Obsah stránky (placeholder – nahraď svým obsahem)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // safeAreaInset se postará o posun obsahu pod horní bar
                    VStack(spacing: 12) {
                        Image(systemName: "house")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                        Text("Domů")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                        Text("Začni navrhovat novou domovskou stránku")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.callout)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer(minLength: 200)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 24)
            }
        }
        // Horní bar přichycený k safe area (iOS-like výška pod stavovou lištou)
        .safeAreaInset(edge: .top, spacing: 0) {
            HomeTopBar(
                circleSize: circleSize,
                searchHeight: searchHeight,
                iconSize: iconSize,
                onAvatar: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onOpenProfile()
                },
                onSearch: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onSearch()
                },
                onRightPrimary: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onOpenHistory()
                },
                onRightSecondary: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onOpenCards()
                }
            )
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 8) // iOS-like svislé odsazení od status baru
            .background(Color.clear)
        }
    }
}

// MARK: - Home Top Bar
private struct HomeTopBar: View {
    let circleSize: CGFloat
    let searchHeight: CGFloat
    let iconSize: CGFloat
    
    var onAvatar: () -> Void
    var onSearch: () -> Void
    var onRightPrimary: () -> Void
    var onRightSecondary: () -> Void
    
    private var tint: Color { .white }
    
    var body: some View {
        HStack(spacing: 10) {
            // Avatar s indikací
            GlassCircleButton(size: circleSize, tint: tint) {
                ZStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: iconSize, weight: .semibold))
                        .foregroundStyle(.white)
                }
            } action: {
                onAvatar()
            }
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .offset(x: -2, y: -2)
                    .accessibilityHidden(true)
            }
            .accessibilityLabel("Profil")
            .accessibilityHint("Otevřít profil")
            
            // Hledání – roztažená pilulka
            SearchBarPill(height: searchHeight, tint: tint, placeholder: "Vyhledat") {
                onSearch()
            }
            .accessibilityLabel("Vyhledat")
            .accessibilityHint("Otevřít vyhledávání")
            
            // Pravé kruhové tlačítko (graf/statistiky)
            GlassCircleButton(size: circleSize, tint: tint) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(.white)
            } action: {
                onRightPrimary()
            }
            .accessibilityLabel("Statistiky")
            
            // Pravé kruhové tlačítko (karta/účtenka)
            GlassCircleButton(size: circleSize, tint: tint) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(.white)
            } action: {
                onRightSecondary()
            }
            .accessibilityLabel("Karty")
        }
        .tint(tint)
    }
}

// MARK: - Building Blocks

// Kulaté tlačítko v „glass“ stylu (iOS 26+: .glassEffect)
private struct GlassCircleButton<Content: View>: View {
    let size: CGFloat
    let tint: Color
    @ViewBuilder var content: () -> Content
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if #available(iOS 26.0, *) {
                    Circle()
                        .fill(.clear)
                        .glassEffect(.regular, in: Circle())
                        .overlay(
                            Circle().fill(tint.opacity(0.20))
                        )
                        .overlay(
                            Circle().strokeBorder(tint.opacity(0.28), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 10)
                } else {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle().fill(tint.opacity(0.18))
                        )
                        .overlay(
                            Circle().strokeBorder(tint.opacity(0.28), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 6)
                }
                
                content()
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// Roztažená pilulka pro vyhledávání v „glass“ stylu
private struct SearchBarPill: View {
    let height: CGFloat
    let tint: Color
    let placeholder: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(placeholder)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.85))
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .frame(height: height)
            .background(
                Group {
                    if #available(iOS 26.0, *) {
                        Capsule()
                            .fill(.clear)
                            .glassEffect(.regular, in: Capsule())
                            .overlay(
                                Capsule().fill(tint.opacity(0.18))
                            )
                            .overlay(
                                Capsule().strokeBorder(tint.opacity(0.22), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 10)
                    } else {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule().fill(tint.opacity(0.16))
                            )
                            .overlay(
                                Capsule().strokeBorder(tint.opacity(0.22), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 6)
                    }
                }
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    HomeView(
        onOpenHistory: {},
        onOpenProfile: {},
        onOpenCards: {},
        onSearch: {}
    )
    .preferredColorScheme(.dark)
}
