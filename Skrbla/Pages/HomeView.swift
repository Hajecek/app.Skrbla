//
//  HomeView.swift
//  Skrbla
//
//  Domovská obrazovka podle aktuálního Revolut layoutu
//  (toolbar search + glass kruhy, centrový balance, quick actions, karty).
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authState: AuthState
    @EnvironmentObject private var financeStore: FinanceStore
    @Environment(\.openAddSheet) private var openAddSheet
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("home.hideBalances") private var hideBalances = false
    @State private var selectedPocket: Int? = 0
    @State private var showSearch = false

    private var pockets: [HomePocket] {
        [
            HomePocket(
                label: "Hlavní · CZK",
                amount: financeStore.remainingBudget,
                pillTitle: "Rozpočet",
                detail: "Zbývá z \(SkrblaTheme.formatCurrency(financeStore.monthlyBudget))"
            ),
            HomePocket(
                label: "Výdaje · měsíc",
                amount: financeStore.thisMonthSpent,
                pillTitle: "Historie",
                detail: "\(financeStore.thisMonthExpenses.count) položek"
            ),
            HomePocket(
                label: "Předplatné · měsíc",
                amount: financeStore.monthlySubscriptionsCost,
                pillTitle: "Správa",
                detail: "\(financeStore.activeSubscriptions.count) aktivních"
            )
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 22) {
                    balanceCarousel
                    quickActions
                    promoCard
                    transactionsBlock
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(pageBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Stejný vzor jako Provikart – systémový Liquid Glass, bez .buttonStyle(.glass)
                ToolbarItemGroup(placement: .topBarLeading) {
                    ProfileBarButton()

                    Button {
                        showSearch = true
                    } label: {
                        Label("Vyhledat", systemImage: "magnifyingglass")
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel("Vyhledat")
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "chart.bar")
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel("Statistiky")

                    NavigationLink {
                        ProfileView()
                    } label: {
                        Image(systemName: "creditcard")
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel("Účet")
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showSearch) {
                NavigationStack {
                    HistoryView()
                }
            }
        }
    }

    // MARK: - Balance carousel (jako Revolut)

    private var balanceCarousel: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(pockets.enumerated()), id: \.offset) { index, pocket in
                        balancePage(pocket, index: index)
                            .containerRelativeFrame(.horizontal)
                            .id(index)
                            .scrollTransition(.animated(.spring(response: 0.38, dampingFraction: 0.86))) { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.35)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.88, anchor: .center)
                                    .blur(radius: phase.isIdentity ? 0 : 1.2)
                                    .offset(y: phase.isIdentity ? 0 : 6)
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $selectedPocket)
            .frame(height: 148)
            .sensoryFeedback(.selection, trigger: selectedPocket)

            // Vlastní tečky níž pod carousel
            HStack(spacing: 7) {
                ForEach(0..<pockets.count, id: \.self) { index in
                    Capsule()
                        .fill(index == (selectedPocket ?? 0) ? Color.primary : Color.secondary.opacity(0.32))
                        .frame(width: index == (selectedPocket ?? 0) ? 18 : 7, height: 7)
                }
            }
            .animation(.spring(response: 0.34, dampingFraction: 0.78), value: selectedPocket)
            .padding(.top, 18)
            .padding(.bottom, 4)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Stránka \((selectedPocket ?? 0) + 1) z \(pockets.count)")
        }
        .padding(.top, 12)
    }

    private func balancePage(_ pocket: HomePocket, index: Int) -> some View {
        VStack(spacing: 10) {
            Text(pocket.label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .contentTransition(.opacity)

            Text(masked(SkrblaTheme.formatCurrency(pocket.amount)))
                .font(.system(size: 48, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .contentTransition(.numericText())

            Group {
                if index == 0 {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        accountsPill(pocket.pillTitle)
                    }
                    .buttonStyle(.plain)
                } else if index == 1 {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        accountsPill(pocket.pillTitle)
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink {
                        SubscriptionView()
                    } label: {
                        accountsPill(pocket.pillTitle)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func accountsPill(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(actionChipFill, in: Capsule())
    }

    // MARK: - Quick actions

    private var quickActions: some View {
        HStack(spacing: 0) {
            quickAction(title: "Přidat", systemImage: "plus") {
                openAddSheet?()
            }

            NavigationLink {
                HistoryView()
            } label: {
                quickActionLabel(title: "Historie", systemImage: "arrow.left.arrow.right")
            }
            .buttonStyle(.plain)

            NavigationLink {
                SubscriptionView()
            } label: {
                quickActionLabel(title: "Předplatné", systemImage: "building.columns")
            }
            .buttonStyle(.plain)

            NavigationLink {
                SettingsView()
            } label: {
                quickActionLabel(title: "Další", systemImage: "ellipsis")
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }

    private func quickAction(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            quickActionLabel(title: title, systemImage: systemImage)
        }
        .buttonStyle(.plain)
    }

    private func quickActionLabel(title: String, systemImage: String) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(actionChipFill)
                    .frame(width: 52, height: 52)
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Promo / insight card

    private var promoCard: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Rozpočet na měsíci")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                Text(promoSubtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [SkrblaTheme.primaryDeep, SkrblaTheme.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 54)
                    .rotationEffect(.degrees(-8))
                    .shadow(color: SkrblaTheme.primary.opacity(0.35), radius: 12, y: 6)

                Text("\(Int(financeStore.budgetProgress * 100))%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(16)
        .background(cardFill, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var promoSubtitle: String {
        let left = SkrblaTheme.formatCurrency(financeStore.remainingBudget)
        return hideBalances
            ? "Sleduj, kolik ti zbývá do limitu."
            : "Zbývá \(left). Utraceno \(SkrblaTheme.formatCurrency(financeStore.thisMonthSpent))."
    }

    // MARK: - Transactions (samostatné karty jako Revolut)

    private var transactionsBlock: some View {
        VStack(spacing: 10) {
            if financeStore.recentExpenses.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                    Text("Zatím žádné výdaje")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Button("Přidat první") { openAddSheet?() }
                        .font(.subheadline.weight(.semibold))
                        .tint(SkrblaTheme.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(cardFill, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            } else {
                ForEach(financeStore.recentExpenses) { expense in
                    NavigationLink {
                        ExpenseDetailView(expense: expense)
                    } label: {
                        RevolutExpenseRow(
                            expense: expense,
                            amountText: masked(SkrblaTheme.formatSignedAmount(expense)),
                            showsDate: true
                        )
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(cardFill, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Helpers

    private func masked(_ value: String) -> String {
        hideBalances ? "••••" : value
    }

    private var actionChipFill: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.12)
            : Color.black.opacity(0.06)
    }

    private var cardFill: Color {
        colorScheme == .dark
            ? Color(red: 0.12, green: 0.13, blue: 0.15)
            : Color.white
    }

    private var pageBackground: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color(uiColor: .systemGroupedBackground))
                .ignoresSafeArea()

            RevolutWaveBackground()
                .opacity(colorScheme == .dark ? 1 : 0.55)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }
}

// MARK: - Model

private struct HomePocket {
    let label: String
    let amount: Double
    let pillTitle: String
    let detail: String
}

// MARK: - Wave background (soudržné paralelní vlnky, společný pohyb)

private struct RevolutWaveBackground: View {
    private let waveCount = 32
    private let blueTint = Color(red: 0.45, green: 0.65, blue: 1.0)

    @State private var driftAngle = Double.random(in: -0.55...0.55)
    @State private var driftSpeed = Double.random(in: 0.28...0.48)

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            waveCanvas(time: time)
        }
    }

    private func waveCanvas(time: TimeInterval) -> some View {
        Canvas { context, size in
            drawWaves(context: context, size: size, time: time)
        }
    }

    private func drawWaves(context: GraphicsContext, size: CGSize, time: TimeInterval) {
        // Společné parametry pro všechny vlnky – hýbou se stejně
        let sharedPhase = time * driftSpeed
        let sharedAmplitudePulse = 0.82 + 0.18 * sin(time * 0.35)
        let sharedWidthPulse = 0.92 + 0.08 * sin(time * 0.22 + 1.1)
        let frequency = 2.15 * sharedWidthPulse
        let baseAmplitude = 26 * sharedAmplitudePulse

        // Jen horní část – po quick actions (Přidat / Historie / Předplatné / Další)
        let topY: CGFloat = -40
        let bottomY = min(size.height * 0.46, 390)
        let spacing = (bottomY - topY) / CGFloat(max(waveCount - 1, 1))

        for i in 0..<waveCount {
            let path = makeWavePath(
                size: size,
                index: i,
                spacing: spacing,
                startY: topY,
                phase: sharedPhase,
                frequency: frequency,
                amplitude: baseAmplitude,
                driftAngle: driftAngle
            )
            let fade = 1 - CGFloat(i) / CGFloat(max(waveCount - 1, 1))
            let alpha = 0.04 + fade * 0.09

            context.stroke(
                path,
                with: .color(Color.white.opacity(alpha * 0.9)),
                lineWidth: 1.05
            )
            context.stroke(
                path,
                with: .color(blueTint.opacity(alpha * 0.38)),
                lineWidth: 0.7
            )
        }
    }

    private func makeWavePath(
        size: CGSize,
        index: Int,
        spacing: CGFloat,
        startY: CGFloat,
        phase: Double,
        frequency: Double,
        amplitude: CGFloat,
        driftAngle: Double
    ) -> Path {
        var path = Path()
        let yBase = startY + CGFloat(index) * spacing
        let safeWidth = max(size.width, 1)
        let slant = CGFloat(tan(driftAngle)) * 0.35

        path.move(to: CGPoint(x: -30, y: yBase))

        var x: CGFloat = -30
        while x <= size.width + 50 {
            let normalizedX = Double(x / safeWidth)
            let angle = normalizedX * Double.pi * frequency + phase
            let wave = CGFloat(sin(angle)) * amplitude
            let y = yBase + wave + x * slant
            path.addLine(to: CGPoint(x: x, y: y))
            x += 5
        }

        return path
    }
}

// MARK: - Revolut-style transaction row

struct RevolutExpenseRow: View {
    let expense: Expense
    var amountText: String
    var showsDate: Bool = false

    private static let dateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "cs_CZ")
        f.dateFormat = "d.M.yyyy, HH:mm"
        return f
    }()

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(categoryTint.opacity(0.22))
                    .frame(width: 46, height: 46)
                Image(systemName: expense.category.systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(categoryTint)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(expense.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                if showsDate {
                    Text(Self.dateTimeFormatter.string(from: expense.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(expense.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(expense.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            Text(amountText)
                .font(.body.weight(.semibold))
                .foregroundStyle(expense.kind == .income ? SkrblaTheme.primary : .primary)
                .lineLimit(1)
        }
        .contentShape(Rectangle())
    }

    private var categoryTint: Color {
        switch expense.category {
        case .food: return SkrblaTheme.primary
        case .transport: return SkrblaTheme.info
        case .housing: return SkrblaTheme.secondaryDeep
        case .shopping: return SkrblaTheme.accent
        case .entertainment: return Color.purple
        case .health: return Color.pink
        case .subscriptions: return SkrblaTheme.accent
        case .other: return .gray
        }
    }
}

/// Kompatibilní řádek pro Historii (List) a ostatní obrazovky.
struct ExpenseRowView: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(SkrblaTheme.primary.opacity(0.16))
                    .frame(width: 40, height: 40)
                Image(systemName: expense.category.systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(SkrblaTheme.primaryDeep)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.body.weight(.semibold))
                Text(expense.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text(SkrblaTheme.formatSignedAmount(expense))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(expense.kind == .income ? SkrblaTheme.primary : .primary)
                Text(SkrblaTheme.formatDate(expense.date, style: .short))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthState())
        .environmentObject(FinanceStore.shared)
        .preferredColorScheme(.dark)
}
