//
//  HomeView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

// MARK: - Home View (Vyčištěno pro nový redesign)
struct HomeView: View {
    var onOpenHistory: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Neutrální tmavé pozadí, aby ladilo se zbytkem aplikace
            Color.black
                .ignoresSafeArea()
            
            // Placeholder – můžeš odstranit, jakmile začneš tvořit nový design
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
            .padding()
        }
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
