//
//  PrivacyScreen.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

struct PrivacyScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Pozadí: obrázek z Asset Catalogu vyplňující celou plochu
            Image("PrivacyScreen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Subtilní branding pro snapshoty
            VStack(spacing: 12) {
                Image(colorScheme == .dark ? "LogoDark" : "Logo")
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
            .preferredColorScheme(.light)
       
}
