import SwiftUI

struct LaunchView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var isTransitioning = false
    
    var body: some View {
        ZStack {
            // Jednoduché pozadí
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .opacity(isTransitioning ? 0 : 1)
            }
            .scaleEffect(isTransitioning ? 1.1 : 1)
            .opacity(isTransitioning ? 0 : 1)
        }
        .onAppear {
            // Animace loga
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1
            }
            
            // Animace textu
            withAnimation(.easeInOut(duration: 0.6).delay(0.4)) {
                textOpacity = 1
            }
            
            // Přechod po 2 sekundách
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isTransitioning = true
                }
            }
        }
    }
}

#Preview {
    LaunchView()
} 
