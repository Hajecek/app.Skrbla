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
    
    // Parametry spodního baru z NavigationBar.swift
    // barHeight ~ 68, spodní vnější padding ~ 8
    private let navBarVisibleHeight: CGFloat = 68 + 8
    // Požadovaná vlastní mezera panelu od spodku (viz obrázek)
    private let desiredBottomInset: CGFloat = 16
    // Doporučené iOS-like zaoblení pro „card/panel“ tvary
    private let panelCornerRadius: CGFloat = 48

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let safeBottom = proxy.safeAreaInsets.bottom
                ZStack(alignment: .bottom) {
                    // Pozadí #362FFA
                    Color(red: 0.211, green: 0.188, blue: 1.0)
                        .ignoresSafeArea()
                    
                    // Černý obdélník dole (zatím prázdný)
                    RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                        .fill(Color.black)
                        .frame(height: 360) // upravte dle potřeby
                        .padding(.horizontal, 16)
                        // Vnější mezera od spodku jako na referenci
                        .padding(.bottom, desiredBottomInset)
                        .overlay(
                            // Volitelná jemná hrana pro iOS feel (ponecháno zakomentované)
                            // RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                            //     .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.6)
                            //     .allowsHitTesting(false)
                            EmptyView()
                        )
                        // Vnitřní spodní padding, který „protáhne“ černou plochu pod plovoucí bar
                        .overlay(
                            VStack { Spacer() }
                                .padding(.bottom, safeBottom + navBarVisibleHeight + 6),
                            alignment: .bottom
                        )
                        .contentShape(RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous))
                }
                .ignoresSafeArea(edges: .bottom) // pozadí jde pod home indikátor
            }
        }
    }
}

#Preview {
    HomeView(onOpenHistory: {})
}
