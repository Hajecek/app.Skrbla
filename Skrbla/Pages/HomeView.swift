//
//  HomeView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

// MARK: - Home View
struct HomeView: View {
    // Callback pro přepnutí na Historii (ponecháno kvůli vazbám z rodiče)
    var onOpenHistory: () -> Void = {}

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Pozadí #3A37FA
                Color(red: 58/255, green: 55/255, blue: 250/255)
                    .ignoresSafeArea()

                // Spodní panel s barvou #121212
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 18/255, green: 18/255, blue: 18/255)) // #121212
                    .frame(height: 300) // upravte dle potřeby, např. 280–340
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12) // malé odsazení od spodního okraje
            }
        }
    }
}

#Preview {
    HomeView(onOpenHistory: {})
}
