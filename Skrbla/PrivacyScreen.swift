//
//  PrivacyScreen.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

struct PrivacyScreen: View {
    var body: some View {
        ZStack {
            // Use a dark background to obscure content
            Color.black.ignoresSafeArea()
            
            // A simple branding element; keep it subtle for snapshots
            VStack(spacing: 12) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Text("Skrbla")
                    .font(.title2.bold())
                    .foregroundStyle(.white.opacity(0.9))
                
                Text("Obsah skryt z důvodu soukromí")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .multilineTextAlignment(.center)
            .padding()
        }
        .accessibilityHidden(true) // Avoid exposing content via VoiceOver when backgrounded
    }
}

#Preview {
    PrivacyScreen()
}
