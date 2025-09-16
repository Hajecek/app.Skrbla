//
//  ProfileView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Profile header
                    VStack(spacing: 16) {
                        // Avatar
                        Circle()
                            .fill(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40))
                            )
                        
                        VStack(spacing: 4) {
                            Text("Michal Hájek")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("michal@skrbla.com")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.top, 40)
                    
                    // Stats
                    HStack(spacing: 20) {
                        StatCard(title: "Položky", value: "24", color: .blue)
                        StatCard(title: "Tento měsíc", value: "8", color: .green)
                        StatCard(title: "Celkem", value: "156", color: .orange)
                    }
                    .padding(.horizontal, 20)
                    
                    // Live Activity sekce
                    VStack(spacing: 16) {
                        HStack {
                            Text("Live Aktivita")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            Button("▶️ Spustit Live Aktivitu") {
                                LiveActivityManager.shared.startActivity()
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)

                            Button("🔄 Aktualizovat Aktivitu") {
                                LiveActivityManager.shared.updateActivity(
                                    currentAmount: 15000,
                                    lastTransaction: "Platba za služby",
                                    amount: 1200,
                                    isPositive: false,
                                    category: "Služby"
                                )
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)

                            Button("🛑 Ukončit Aktivitu") {
                                LiveActivityManager.shared.endActivity()
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Menu options
                    VStack(spacing: 12) {
                        ProfileMenuRow(
                            icon: "person.circle",
                            title: "Upravit profil",
                            color: .blue
                        ) {
                            // Action
                        }
                        
                        ProfileMenuRow(
                            icon: "bell",
                            title: "Notifikace",
                            color: .orange
                        ) {
                            // Action
                        }
                        
                        ProfileMenuRow(
                            icon: "lock",
                            title: "Soukromí",
                            color: .green
                        ) {
                            // Action
                        }
                        
                        ProfileMenuRow(
                            icon: "questionmark.circle",
                            title: "Nápověda",
                            color: .purple
                        ) {
                            // Action
                        }
                        
                        ProfileMenuRow(
                            icon: "gear",
                            title: "Nastavení",
                            color: .gray
                        ) {
                            // Action
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Logout button
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .font(.system(size: 18))
                            
                            Text("Odhlásit se")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.1))
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Stat Card
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

// MARK: - Profile Menu Row
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
    ProfileView()
}

