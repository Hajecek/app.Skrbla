//
//  HomeView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

// MARK: - Home View
struct HomeView: View {
    // Placeholder hodnoty – později napoj na reálná data
    @State private var monthlySpent: Decimal = 12345.67
    @State private var monthlyBudget: Decimal = 20000 // TODO: nahradit reálným zdrojem rozpočtu
    @Environment(\.locale) private var locale
    
    // Callback, který přepne tab na Historii (předává ContentView)
    var onOpenHistory: () -> Void = {}
    
    // Laditelné konstanty pro výšku zeleného pozadí
    private let headerHeight: CGFloat = 44 /* titulek + podtitulek + odskoky */
    private let headerTopPadding: CGFloat = 12
    private let headerBottomPadding: CGFloat = 8
    private let cardEstimatedHeight: CGFloat = 112 /* karta je jednodušší, ale vyšší kvůli iOS spacingu */
    private let verticalSpacingBetweenHeaderAndCard: CGFloat = 16
    private let horizontalPadding: CGFloat = 20

    // Animace horního zeleného pozadí
    @State private var backgroundReveal: CGFloat = 0
    @State private var backgroundOpacity: CGFloat = 0
    @State private var gradientOffset: CGFloat = -24

    // Animace karty
    @State private var cardOpacity: CGFloat = 0
    @State private var cardScale: CGFloat = 0.96

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Zelené pozadí s příjezdovou animací (výška + opacita + jemný parallax offset)
                GradientBackground(opacity: backgroundOpacity)
                    .frame(height: backgroundReveal)
                    .offset(y: gradientOffset)
                    .ignoresSafeArea(edges: .top)
                    .accessibilityHidden(true)
                
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

                    // Karta s měsíční útratou -> po kliknutí přepne na Historii
                    Button(action: onOpenHistory) {
                        MonthlySpendingCard(
                            amount: monthlySpent,
                            budget: monthlyBudget,
                            currencyCode: Locale.current.currency?.identifier
                        )
                        .opacity(cardOpacity)
                        .scaleEffect(cardScale, anchor: .top)
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
                // Reset pro případ návratu na obrazovku
                backgroundReveal = 0
                backgroundOpacity = 0
                gradientOffset = -24
                cardOpacity = 0
                cardScale = 0.96
                
                // 1) Gradient – výška (spring) + opacita (ease)
                withAnimation(.spring(response: 0.55, dampingFraction: 0.9, blendDuration: 0.2)) {
                    backgroundReveal = greenBackgroundHeight
                }
                withAnimation(.easeOut(duration: 0.38).delay(0.03)) {
                    backgroundOpacity = 1
                }
                // 2) Gradient – jemný posun dolů pro parallax dojem
                withAnimation(.spring(response: 0.6, dampingFraction: 0.88, blendDuration: 0.2).delay(0.02)) {
                    gradientOffset = 0
                }
                // 3) Karta – fade + scale s malým zpožděním za gradientem
                withAnimation(.spring(response: 0.5, dampingFraction: 0.92, blendDuration: 0.2).delay(0.12)) {
                    cardOpacity = 1
                    cardScale = 1.0
                }
            }
        }
    }
    
    // Výpočet výšky zeleného pozadí tak, aby pokrylo banner + mezeru + kartu
    private var greenBackgroundHeight: CGFloat {
        let bannerApproxHeight = headerHeight + headerTopPadding + headerBottomPadding
        let total = bannerApproxHeight + verticalSpacingBetweenHeaderAndCard + cardEstimatedHeight + 60 /* rezerva */
        return total
    }
}

// MARK: - Monthly Spending Card
private struct MonthlySpendingCard: View {
    let amount: Decimal
    let budget: Decimal
    let currencyCode: String?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Leading icon badge for iOS affordance
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.thinMaterial)
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.tint)
            }
            .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(monthTitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text(formattedAmount(amount))
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()

                Text("Utraceno v aktuálním měsíci")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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

// MARK: - Gradient Background (zelený přechod pro horní část)
private struct GradientBackground: View {
    @Environment(\.colorScheme) private var scheme
    var opacity: CGFloat = 1
    
    var body: some View {
        let top = Color.green.opacity((scheme == .dark ? 0.35 : 0.25) * opacity)
        let mid = Color.green.opacity((scheme == .dark ? 0.22 : 0.16) * opacity)
        let clear = Color.green.opacity(0.0)
        
        LinearGradient(
            colors: [top, mid, clear],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    HomeView(onOpenHistory: {})
}
