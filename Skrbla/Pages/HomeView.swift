//
//  HomeView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

// MARK: - Home View
struct HomeView: View {
    // Placeholder hodnota – později napoj na reálná data
    @State private var monthlySpent: Decimal = 12345.67
    @Environment(\.locale) private var locale
    
    // Callback, který přepne tab na Historii (předává ContentView)
    var onOpenHistory: () -> Void = {}

    var body: some View {
        NavigationStack {
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
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20) // zvětšená mezera pod hlavičkou

                // Karta s měsíční útratou -> po kliknutí přepne na Historii
                Button(action: onOpenHistory) {
                    MonthlySpendingCard(amount: monthlySpent, currencyCode: Locale.current.currency?.identifier)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Otevřít historii výdajů za tento měsíc")

                // 🔹 Tlačítka pro práci s Live Activity
                VStack(spacing: 12) {
                    Button("▶️ Spustit Live Aktivitu") {
                        LiveActivityManager.shared.startActivity()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("🔄 Aktualizovat Aktivitu") {
                        LiveActivityManager.shared.updateActivity(
                            currentAmount: 15000,
                            lastTransaction: "Platba za služby",
                            amount: 1200,
                            isPositive: false,
                            category: "Služby"
                        )
                    }
                    .buttonStyle(.bordered)

                    Button("🛑 Ukončit Aktivitu") {
                        LiveActivityManager.shared.endActivity()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding(.top, 20)

                Spacer()
            }
            // Skrytí systémového navigation baru, aby se nezdvojoval s vlastní hlavičkou
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .background(.background)
        }
    }
}

// MARK: - Monthly Spending Card
private struct MonthlySpendingCard: View {
    let amount: Decimal
    let currencyCode: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(monthTitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Velká částka v systémovém fontu
                    Text(formattedAmount)
                        .font(.title.weight(.semibold))
                        .monospacedDigit()
                }

                Spacer()

                // Placeholder pro případnou ikonku/trend do budoucna
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.tint)
                    .opacity(0.9)
            }

            // Volitelný podřádek s doplňujícím textem
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
        .padding(.top, 12)
    }

    private var formattedAmount: String {
        let code = currencyCode ?? "CZK"
        // Swift FormatStyle pro měnu, respektuje lokalizaci
        if let doubleValue = NSDecimalNumber(decimal: amount).doubleValue as Double? {
            return doubleValue.formatted(.currency(code: code))
        }
        return "—"
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

#Preview {
    HomeView(onOpenHistory: {})
}
