//
//  HistoryView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

// MARK: - History View (Vyčištěno pro nový redesign)
struct HistoryView: View {    
    var body: some View {
        ZStack {
            // Neutrální tmavé pozadí ladící se zbytkem aplikace
            Color.black
                .ignoresSafeArea()
            
            // Placeholder – můžeš odstranit, až začneš tvořit nový design
            VStack(spacing: 12) {
                Image(systemName: "clock")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                Text("Historie")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                Text("Začni navrhovat novou stránku historie")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.callout)
            }
            .padding()
        }
    }
}

#Preview {
    HistoryView()
        .preferredColorScheme(.dark)
}
