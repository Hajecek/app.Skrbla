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
        // Prázdný obsah – tab bar zůstává viditelný, protože je řízený rodičem (TabView/MainContentView)
        NavigationStack {
            Color.clear
                .ignoresSafeArea() // žádný vlastní obsah, žádné překryvy
        }
    }
}

#Preview {
    HomeView(onOpenHistory: {})
}
