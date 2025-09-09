//
//  AddView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

// MARK: - Add View
struct AddView: View {
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Text("Přidat položku")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Vytvořte novou položku")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 40)
                
                // Add options
                VStack(spacing: 20) {
                    AddOptionCard(
                        title: "Přidat ručně",
                        subtitle: "Zadejte informace ručně",
                        icon: "pencil.circle.fill",
                        color: .blue
                    ) {
                        // Action
                    }
                    
                    AddOptionCard(
                        title: "Skenovat čárový kód",
                        subtitle: "Naskenujte čárový kód",
                        icon: "barcode.viewfinder",
                        color: .green
                    ) {
                        // Action
                    }
                    
                    AddOptionCard(
                        title: "Rozpoznat obrázek",
                        subtitle: "Použijte AI rozpoznávání",
                        icon: "camera.fill",
                        color: .orange
                    ) {
                        // Action
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

// MARK: - Add Option Card
struct AddOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(color)
                            .font(.system(size: 24))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.4))
                    .font(.system(size: 16))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddView()
}
