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
    private let headerBottomPadding: CGFloat = 14
    private let cardEstimatedHeight: CGFloat = 100 /* sníženo, karta je nyní jednodušší */
    private let verticalSpacingBetweenHeaderAndCard: CGFloat = 20
    private let horizontalPadding: CGFloat = 20

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Zelené pozadí od horního okraje po spodní hranu karty
                GradientBackground()
                    .frame(height: greenBackgroundHeight)
                    .ignoresSafeArea(edges: .top)
                
                VStack(spacing: 20) {
                    // Horní lišta: nadpis vlevo, profil vpravo (stejná úroveň)
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Vítej zpátky 👋")
                                .font(.largeTitle.weight(.bold)) // hlavní Apple font (SF)
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
                    .padding(.bottom, headerBottomPadding) // zmenšená mezera pod hlavičkou, aby karta byla výš

                    // Karta s měsíční útratou -> po kliknutí přepne na Historii
                    Button(action: onOpenHistory) {
                        MonthlySpendingCard(
                            amount: monthlySpent,
                            budget: monthlyBudget,
                            currencyCode: Locale.current.currency?.identifier
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Otevřít historii výdajů za tento měsíc")

                    Spacer()
                }
            }
            // Skrytí systémového navigation baru, aby se nezdvojoval s vlastní hlavičkou
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .background(.background)
        }
    }
    
    // Výpočet výšky zeleného pozadí tak, aby pokrylo banner + mezeru + kartu
    private var greenBackgroundHeight: CGFloat {
        // Odhad: horní padding + (vizuální) výška banneru + spodní padding + mezera + výška karty + rezerva
        let bannerApproxHeight = headerHeight + headerTopPadding + headerBottomPadding
        let total = bannerApproxHeight + verticalSpacingBetweenHeaderAndCard + cardEstimatedHeight + 70 /* rezerva */
        return total
    }
}

// MARK: - Monthly Spending Card
private struct MonthlySpendingCard: View {
    let amount: Decimal
    let budget: Decimal
    let currencyCode: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Horní řádek: název měsíce a případná ikonka
            HStack(alignment: .firstTextBaseline) {
                Text(monthTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                // Placeholder pro případnou ikonku/trend do budoucna
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.tint)
                    .opacity(0.9)
            }

            // Velká částka v systémovém fontu
            Text(formattedAmount(amount))
                .font(.title.weight(.semibold))
                .monospacedDigit()

            // Popisek pod částkou
            Text("Utraceno v aktuálním měsíci")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .background(
            // Jemné podbarvení pro lepší kontrast v tmavém režimu
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(0.04))
        )
        .padding(.horizontal, 20)
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
    
    var body: some View {
        let top = Color.green.opacity(scheme == .dark ? 0.35 : 0.25)
        let mid = Color.green.opacity(scheme == .dark ? 0.22 : 0.16)
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
