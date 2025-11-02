//
//  HomeView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

// MARK: - Home View
struct HomeView: View {
    var onOpenHistory: () -> Void = {}
    
    @State private var selectedScope: Scope = .day
    @State private var weeklySteps: [DayBar] = DayBar.mockCZ
    @State private var selectedIndex: Int? = 0 // Po
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                RadialBlueBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HeaderStats()
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    
                    WeeklyBarChart(
                        bars: weeklySteps,
                        selectedIndex: $selectedIndex
                    )
                    .frame(height: 400)
                    .padding(.horizontal, 24)
                    .padding(.top, 12) // dny nebudeme posouvat – posouváme jen sloupce uvnitř
                    .padding(.bottom, 0)
                    
                    Spacer(minLength: 16)
                }
                
                BigStatsCard(
                    scope: $selectedScope,
                    steps: 715,
                    distanceKm: 0.58,
                    calories: 93.5,
                    floors: 2,
                    onStepsTap: {},
                    onVoiceTap: { onOpenHistory() }
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Background
private struct RadialBlueBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 58/255, green: 55/255, blue: 250/255), // #3A37FA
                    Color(red: 60/255, green: 90/255, blue: 255/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.10),
                        Color.clear
                    ]),
                    center: .init(x: 0.7, y: 0.2),
                    startRadius: 40,
                    endRadius: 420
                )
            )
        }
    }
}

// MARK: - Header stats row
private struct HeaderStats: View {
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.white.opacity(0.75))
                    Text("1 501")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer(minLength: 0)
                }
                Text("Steps behind")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .background(Color.white.opacity(0.2))
                .frame(height: 38)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(.orange)
                    Text("67%")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(.orange)
                    Spacer(minLength: 0)
                }
                Text("Lower than yesterday")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                // např. Water reminder
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .frame(width: 66, height: 44)
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Bar chart
struct DayBar: Identifiable {
    let id = UUID()
    let day: String
    let value: Double // steps
    let color: Color
    
    // CZ pořadí od pondělí
    static let mockCZ: [DayBar] = [
        .init(day: "Po", value: 10, color: .white.opacity(0.45)),
        .init(day: "Út", value: 1100, color: .white.opacity(0.25)),
        .init(day: "St", value: 1200, color: .white.opacity(0.18)),
        .init(day: "Čt", value: 900,  color: .white.opacity(0.22)),
        .init(day: "Pá", value: 1800, color: .white.opacity(0.35)),
        .init(day: "So", value: 7200, color: .white.opacity(0.8)),
        .init(day: "Ne", value: 4100, color: .white.opacity(0.55))
    ]
}

private struct WeeklyBarChart: View {
    let bars: [DayBar]
    @Binding var selectedIndex: Int?
    
    // volnější dělení s mezerami
    private let yTicks: [Int] = [17, 13, 10, 8, 6, 5, 3, 2, 1]
    
    private var maxValue: Double {
        max(bars.map { $0.value }.max() ?? 1, 1)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                // levé popisky + linky
                VStack(alignment: .leading, spacing: 0) {
                    GeometryReader { geo in
                        let total = CGFloat(yTicks.count - 1)
                        ZStack(alignment: .topLeading) {
                            ForEach(Array(yTicks.enumerated()), id: \.offset) { idx, k in
                                let y = (CGFloat(idx) / total) * (geo.size.height - 0.001)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(k)K")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.white.opacity(0.50))
                                        .offset(y: -8)
                                    Rectangle()
                                        .fill(Color.white.opacity(k % 2 == 0 ? 0.06 : 0.03))
                                        .frame(height: 1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .position(x: 16, y: y)
                            }
                        }
                    }
                }
                .frame(width: 34)
                
                // sloupce – posuneme je níž pomocí topReserved, dny zůstanou
                GeometryReader { geo in
                    let reservedBottom: CGFloat = 0   // minimální mezera pro popisky dnů
                    let topReserved: CGFloat = 64     // VÍCE DOLŮ: větší horní rezerva jen pro sloupce
                    let usableHeight = max(0, geo.size.height - reservedBottom - topReserved)
                    
                    HStack(alignment: .bottom) {
                        ForEach(Array(bars.enumerated()), id: \.offset) { index, bar in
                            let h = max(10, (bar.value / maxValue) * max(0, (usableHeight - 10)))
                            
                            // Sloupec
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.85),
                                            Color.white.opacity(0.42)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ).opacity(index == selectedIndex ? 1.0 : 0.7)
                                )
                                .frame(width: 28, height: h)
                                // Vnitřní jemný highlight (“skleněný” efekt)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                                )
                                .overlay(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.16),
                                            Color.white.opacity(0.0)
                                        ],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                )
                                // Silnější měkký stín
                                .shadow(color: .black.opacity(0.28), radius: 22, x: 0, y: 18)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        selectedIndex = index
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .bottom)
                                // Spodní glow – malý a blízko dnům
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(index == selectedIndex ? 0.35 : 0.25),
                                                        Color.white.opacity(0.0)
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .frame(width: 40, height: 20)
                                            .blur(radius: 14)
                                            .offset(y: 4)
                                            .opacity(0.9)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .bottom)
                                )
                        }
                    }
                    .padding(.top, topReserved) // posun pouze na sloupce
                }
            }
            .padding(.leading, 0)
            
            // spodní dny (CZ, od Po) – vždy viditelné, bez posunu
            HStack {
                Spacer(minLength: 36)
                ForEach(bars) { bar in
                    Text(bar.day)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 2)
        }
    }
}

// MARK: - Big card
private enum Scope: String, CaseIterable { case day = "D", week = "W", month = "M" }

private struct BigStatsCard: View {
    @Binding var scope: Scope
    let steps: Int
    let distanceKm: Double
    let calories: Double
    let floors: Int
    var onStepsTap: () -> Void
    var onVoiceTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                // toggle (jen dekor)
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 2)
                        .frame(width: 84, height: 44)
                    HStack(spacing: 6) {
                        Circle().fill(Color.white.opacity(0.9)).frame(width: 26, height: 26)
                        Circle().fill(Color.white.opacity(0.2)).frame(width: 26, height: 26)
                    }
                }
                
                Spacer()
                
                SegmentedPill(selection: $scope, items: Scope.allCases)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(steps)")
                        .font(.system(size: 64, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.5)
                    Text("CZK")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                // Původní samostatný řádek s "CZK" byl odstraněn
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(red: 18/255, green: 18/255, blue: 18/255))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 20, x: 0, y: 10)
        )
    }
}

private struct SegmentedPill<T: Hashable & RawRepresentable & CaseIterable>: View where T.RawValue == String {
    @Binding var selection: T
    let items: [T]
    
    init(selection: Binding<T>, items: [T]) {
        self._selection = selection
        self.items = items
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.self) { item in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                        selection = item
                    }
                } label: {
                    Text(item.rawValue)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(selection == item ? .black : .white.opacity(0.85))
                        .frame(width: 44, height: 36)
                        .background(
                            Capsule()
                                .fill(selection == item ? .white : .clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.08))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HomeView(onOpenHistory: {})
        .preferredColorScheme(.dark)
}
