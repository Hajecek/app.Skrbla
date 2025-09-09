//
//  HomeView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

// MARK: - Home View
struct HomeView: View {
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vítejte v Skrbla")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Vaše moderní aplikace")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Profile button
                    Button(action: {}) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 20))
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Main content area
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Quick actions
                        HStack(spacing: 16) {
                            QuickActionCard(
                                title: "Přidat položku",
                                icon: "plus.circle.fill",
                                color: .green
                            ) {
                                // Action
                            }
                            
                            QuickActionCard(
                                title: "Historie",
                                icon: "clock.fill",
                                color: .orange
                            ) {
                                // Action
                            }
                        }
                        
                        // Recent items
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Nedávné položky")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ForEach(0..<3) { index in
                                RecentItemCard(index: index)
                            }
                        }
                        .padding(.top, 20)
                    }
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(color.opacity(0.1))
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Recent Item Card
struct RecentItemCard: View {
    let index: Int
    
    private let colors: [Color] = [.blue, .green, .orange, .purple]
    private let titles = ["Položka 1", "Položka 2", "Položka 3"]
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(colors[index % colors.count].opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(colors[index % colors.count])
                        .font(.system(size: 20))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(titles[index])
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Přidáno před \(index + 1) hodinami")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
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
        .padding(.horizontal, 20)
    }
}

#Preview {
    HomeView()
}
