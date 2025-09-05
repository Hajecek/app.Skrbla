import SwiftUI

struct LaunchView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var yOffset: CGFloat = 20
    @State private var isTransitioning = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "sportscourt")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .scaleEffect(scale)
                    .opacity(isTransitioning ? 0 : 1)
                
                Text("RefTrack")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .opacity(opacity)
                    .offset(y: yOffset)
                    .opacity(isTransitioning ? 0 : 1)
            }
            .scaleEffect(isTransitioning ? 1.2 : 1)
            .opacity(isTransitioning ? 0 : 1)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
                scale = 1.0
            }
            
            withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
                opacity = 1
                yOffset = 0
            }
            
            // Spustíme přechodovou animaci po 1.5 sekundách
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.4)) {
                    isTransitioning = true
                }
            }
        }
    }
} 