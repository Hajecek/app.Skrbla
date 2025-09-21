//
//  HomeView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

// MARK: - Home View
struct HomeView: View {
    // Sdílený zdroj pravdy – hodnoty jdou do karty i do tabbar accessory
    @EnvironmentObject var finance: FinanceStore
    @Environment(\.locale) private var locale
    
    // Callback, který přepne tab na Historii (předává ContentView)
    var onOpenHistory: () -> Void = {}
    
    // Laditelné konstanty pro výšku zeleného pozadí
    private let headerHeight: CGFloat = 44 /* titulek + podtitulek + odskoky */
    private let headerTopPadding: CGFloat = 12
    private let headerBottomPadding: CGFloat = 8
    private let cardEstimatedHeight: CGFloat = 118 /* karta trochu vyšší kvůli novému layoutu */
    private let verticalSpacingBetweenHeaderAndCard: CGFloat = 18
    private let horizontalPadding: CGFloat = 20

    // Animace horního zeleného pozadí
    @State private var backgroundHeight: CGFloat = 0
    @State private var backgroundOpacity: CGFloat = 0
    @State private var backgroundOffsetY: CGFloat = -24
    @State private var backgroundPulse: CGFloat = 0 // 0..1 pulsace

    // Animace hlavičky
    @State private var headerOpacity: CGFloat = 0
    @State private var headerOffsetY: CGFloat = 10
    @State private var headerTilt: CGFloat = 5 // deg

    // Animace karty
    @State private var cardOpacity: CGFloat = 0
    @State private var cardScale: CGFloat = 0.93
    @State private var cardShadowBoost: CGFloat = 1.12 // násobič stínu při příjezdu
    @State private var triggerBackgroundSweep: Bool = false

    // Jemný parallax podle polohy kurzoru/dotyku (bez CoreMotion)
    @State private var parallax: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Zelené pozadí – vícevrstvý gradient s highlightem, bez šumu, bez wipe masky
                CleanGreenBackground(opacity: backgroundOpacity, pulse: backgroundPulse)
                    .frame(height: backgroundHeight)
                    .offset(x: parallax.width * 0.22,
                            y: backgroundOffsetY + parallax.height * 0.16)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                    )
                    .padding(.top, -26) // přetáhneme za status bar
                    .ignoresSafeArea(edges: .top)
                    .accessibilityHidden(true)
                    .overlay(
                        // Jemná spodní vinetace pro hloubku (bez “přejezdu”)
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.0),
                                Color.black.opacity(0.06)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .padding(.top, -26)
                        .allowsHitTesting(false)
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                // Jemný parallax na základě dotyku/kurzoru
                                let w = UIScreen.main.bounds.width
                                let h = max(1, backgroundHeight)
                                let px = (value.location.x / w - 0.5) * 14
                                let py = (value.location.y / h - 0.5) * 10
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.92)) {
                                    parallax = .init(width: px, height: py)
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.55, dampingFraction: 0.92)) {
                                    parallax = .zero
                                }
                            }
                    )
                
                VStack(spacing: 0) {
                    // Horní lišta: nadpis vlevo, profil vpravo (stejná úroveň)
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Vítej zpátky 👋")
                                .font(.largeTitle.weight(.bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Text("Rád tě zase vidím")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }

                        Spacer()

                        Button {
                            // Akce profilu
                        } label: {
                            ProfileBadge(size: 44, symbolSize: 22)
                        }
                        .accessibilityLabel("Profil")
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, headerTopPadding)
                    .padding(.bottom, headerBottomPadding)
                    .opacity(headerOpacity)
                    .offset(y: headerOffsetY)
                    .rotation3DEffect(.degrees(headerTilt), axis: (x: 1, y: 0, z: 0), anchor: .top, perspective: 0.6)

                    // Karta s měsíční útratou -> po kliknutí přepne na Historii
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            cardScale = 0.98
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                cardScale = 1.0
                            }
                        }
                        onOpenHistory()
                    }) {
                        MonthlySpendingCard(
                            amount: finance.monthlySpent,
                            budget: finance.monthlyBudget,
                            currencyCode: finance.currencyCode,
                            backgroundSweep: triggerBackgroundSweep
                        )
                        .opacity(cardOpacity)
                        .scaleEffect(cardScale, anchor: .top)
                        .shadow(color: Color.black.opacity(0.10 * cardShadowBoost),
                                radius: 14 * cardShadowBoost,
                                x: 0, y: 8 * cardShadowBoost)
                        .offset(x: parallax.width * 0.06, y: parallax.height * 0.05)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, verticalSpacingBetweenHeaderAndCard)
                    .padding(.horizontal, horizontalPadding)
                    .accessibilityHint("Otevřít historii výdajů za tento měsíc")

                    Spacer(minLength: 0)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .background(.background)
            .onAppear {
                playIntro()
            }
        }
    }
    
    // Výpočet výšky zeleného pozadí tak, aby pokrylo banner + mezeru + kartu
    private var greenBackgroundHeight: CGFloat {
        let bannerApproxHeight = headerHeight + headerTopPadding + headerBottomPadding
        let total = bannerApproxHeight + verticalSpacingBetweenHeaderAndCard + cardEstimatedHeight + 72 /* rezerva */
        return total
    }
    
    // Choreografie vstupu (bez viditelného “přejezdu” a bez šumu)
    private func playIntro() {
        // Reset pro případ návratu na obrazovku
        backgroundHeight = 0
        backgroundOpacity = 0
        backgroundOffsetY = -28
        backgroundPulse = 0

        headerOpacity = 0
        headerOffsetY = 12
        headerTilt = 7

        cardOpacity = 0
        cardScale = 0.9
        cardShadowBoost = 1.2
        triggerBackgroundSweep = false
        
        // 1) Pozadí – výška (spring) + opacita (ease) + posun
        withAnimation(.spring(response: 0.6, dampingFraction: 0.92, blendDuration: 0.2)) {
            backgroundHeight = greenBackgroundHeight
        }
        withAnimation(.easeOut(duration: 0.45).delay(0.02)) {
            backgroundOpacity = 1
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.9, blendDuration: 0.2).delay(0.02)) {
            backgroundOffsetY = 0
        }
        // 1.1) Jemný puls highlightu po usazení
        withAnimation(.easeInOut(duration: 1.6).delay(0.28)) {
            backgroundPulse = 1
        }
        // 2) Hlavička – fade + slide + 3D tilt dolů a zpět
        withAnimation(.spring(response: 0.5, dampingFraction: 0.95, blendDuration: 0.2).delay(0.12)) {
            headerOpacity = 1
            headerOffsetY = 0
        }
        withAnimation(.spring(response: 0.65, dampingFraction: 0.9).delay(0.12)) {
            headerTilt = 0
        }
        // 3) Karta – hero-pop: fade + scale, poté jemné dosednutí (shadow boost -> normal)
        withAnimation(.spring(response: 0.55, dampingFraction: 0.88, blendDuration: 0.2).delay(0.2)) {
            cardOpacity = 1
            cardScale = 1.0
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.34)) {
            cardShadowBoost = 1.0
        }
        // 4) Spusť průjezd změny pozadí uvnitř karty (ne přes obsah)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            triggerBackgroundSweep = true
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                triggerBackgroundSweep = false
            }
        }
    }
}

// MARK: - Čistý zelený background (lineární + jemný radiální highlight, bez “šumu” a bez wipe)
private struct CleanGreenBackground: View {
    @Environment(\.colorScheme) private var scheme
    var opacity: CGFloat = 1
    var pulse: CGFloat = 0 // 0..1

    var body: some View {
        let baseTop = Color.green.opacity((scheme == .dark ? 0.36 : 0.28) * opacity)
        let baseMid = Color.green.opacity((scheme == .dark ? 0.24 : 0.18) * opacity)
        let baseClear = Color.green.opacity(0.0)
        
        ZStack {
            // Hlavní lineární gradient
            LinearGradient(
                colors: [baseTop, baseMid, baseClear],
                startPoint: .top,
                endPoint: .bottom
            )
            // Jemný radiální highlight (pulsuje decentně)
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.14 * opacity * (0.7 + 0.3 * pulse)),
                    Color.white.opacity(0.0)
                ]),
                center: .init(x: 0.28, y: 0.1),
                startRadius: 10,
                endRadius: 210 + 24 * pulse
            )
            .blendMode(.screen)
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Monthly Spending Card (background sweep uvnitř pozadí)
private struct MonthlySpendingCard: View {
    let amount: Decimal
    let budget: Decimal
    let currencyCode: String?
    let backgroundSweep: Bool

    private let cornerRadius: CGFloat = 18
    private let minHeight: CGFloat = 76

    var body: some View {
        // Výška a padding stejné jako dřív; background se klipuje do stejného cornerRadius
        HStack(spacing: 0) {
            ContentLayer(amount: amount, budget: budget, currencyCode: currencyCode)
                .padding(16)
        }
        .frame(minHeight: minHeight, alignment: .center)
        .background {
            BackgroundLayer(cornerRadius: cornerRadius, sweep: backgroundSweep)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.07), lineWidth: 0.6)
        )
        .shadow(color: Color.black.opacity(0.10), radius: 14, x: 0, y: 8)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    // MARK: Background only
    private struct BackgroundLayer: View {
        let cornerRadius: CGFloat
        let sweep: Bool

        var body: some View {
            ZStack {
                // Base materials/colors
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.primary.opacity(0.05))

                // Sheen that affects only the background
                SheenBackgroundSweep(active: sweep, cornerRadius: cornerRadius)
            }
        }
    }

    // MARK: Content only
    private struct ContentLayer: View {
        let amount: Decimal
        let budget: Decimal
        let currencyCode: String?

        var body: some View {
            HStack(alignment: .center, spacing: 12) {
                // Leading icon badge
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.thinMaterial)
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.tint)
                }
                .frame(width: 44, height: 44)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(monthTitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    // Dominantní částka
                    Text(formattedAmount(amount))
                        .font(.largeTitle.weight(.bold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    Text("Utraceno v aktuálním měsíci")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }

        private func formattedAmount(_ value: Decimal) -> String {
            let code = currencyCode ?? "CZK"
            let doubleValue = NSDecimalNumber(decimal: value).doubleValue
            return doubleValue.formatted(.currency(code: code))
        }
        
        private var monthTitle: String {
            // Vždy česky: například "září 2025" -> s velkým písmenem "Září 2025"
            let csLocale = Locale(identifier: "cs_CZ")
            let raw = Date().formatted(
                Date.FormatStyle()
                    .locale(csLocale)
                    .month(.wide)
                    .year(.defaultDigits)
            )
            return raw.prefix(1).uppercased() + raw.dropFirst()
        }
    }
}

// MARK: - Background-only sheen sweep (clipped inside background)
private struct SheenBackgroundSweep: View {
    var active: Bool
    var cornerRadius: CGFloat

    @State private var progress: CGFloat = -0.35

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let bandWidth = w * 0.30
            let travel = w + bandWidth

            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0.00),
                            .init(color: .white.opacity(0.10), location: 0.42),
                            .init(color: .white.opacity(0.22), location: 0.50),
                            .init(color: .white.opacity(0.10), location: 0.58),
                            .init(color: .clear, location: 1.00)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: bandWidth, height: h * 1.6)
                .rotationEffect(.degrees(18))
                .offset(x: progress * travel, y: -h * 0.28)
                .opacity(active ? 1 : 0)
                .allowsHitTesting(false)
                .onChange(of: active) { _, new in
                    if new {
                        progress = -0.35
                        withAnimation(.easeInOut(duration: 0.9)) {
                            progress = 1.15
                        }
                    }
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Profile Badge
private struct ProfileBadge: View {
    var size: CGFloat = 36
    var symbolSize: CGFloat = 16

    var body: some View {
        ZStack {
            Circle()
                .fill(.thinMaterial)
                .frame(width: size, height: size)

            Image(systemName: "person.fill")
                .font(.system(size: symbolSize, weight: .semibold))
                .foregroundStyle(.tint)
        }
        .contentShape(Circle())
    }
}

#Preview {
    HomeView(onOpenHistory: {})
        .environmentObject(FinanceStore())
}
