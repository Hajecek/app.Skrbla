//
//  NavigationBar.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

// MARK: - Tab Item Model
struct TabItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let selectedIcon: String?
    
    init(title: String, icon: String, selectedIcon: String? = nil) {
        self.title = title
        self.icon = icon
        self.selectedIcon = selectedIcon
    }
}

// MARK: - Default Tabs Configuration
extension TabItem {
    // Titulky ponechány pro přístupnost, v UI se nezobrazují
    static let home = TabItem(title: "Domů", icon: "house", selectedIcon: "house.fill")
    static let add = TabItem(title: "Přidat", icon: "dot.radiowaves.left.and.right", selectedIcon: "dot.radiowaves.left.and.right")
    static let history = TabItem(title: "Historie", icon: "music.note.list", selectedIcon: "music.note.list")
    static let subscription = TabItem(title: "Předplatné", icon: "calendar", selectedIcon: "calendar")
    static let profile = TabItem(title: "Profil", icon: "person", selectedIcon: "person.fill")
    
    // Pořadí: Domů, Přidat, Historie, Předplatné, Profil
    static let defaultTabs: [TabItem] = [.home, .add, .history, .subscription, .profile]
}

// MARK: - Floating Navigation Bar (Capsule) + Separate Round Button
struct ModernBottomNavigationBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    var onPlusTapped: () -> Void = {}
    @Namespace private var animation
    
    // iOS-like sizing tuned to the reference (no labels)
    private let barHeight: CGFloat = 68
    private let bubbleHeight: CGFloat = 54   // bublina nižší než pilulka
    private let bubbleWidth: CGFloat = 64    // širší pro „chip“ dojem jako na obrázku
    private let iconSize: CGFloat = 22
    private let horizontalPadding: CGFloat = 24
    private let innerHorizontalPadding: CGFloat = 12
    private let innerVerticalPadding: CGFloat = 8
    private let spacingBetweenPillAndButton: CGFloat = 12
    private let roundButtonSize: CGFloat = 64
    
    private var tabColor: Color { Color("TabColor") }
    
    var body: some View {
        HStack(spacing: spacingBetweenPillAndButton) {
            // Main capsule container with tabs
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                    CapsuleTabButton(
                        tab: tab,
                        isSelected: selectedTab == index,
                        animation: animation,
                        bubbleSize: CGSize(width: bubbleWidth, height: bubbleHeight),
                        iconSize: iconSize,
                        tabColor: tabColor
                    ) {
                        withAnimation(.interpolatingSpring(stiffness: 520, damping: 32)) {
                            selectedTab = index
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, innerHorizontalPadding)
            .padding(.vertical, innerVerticalPadding)
            .frame(height: barHeight)
            .background(
                Group {
                    if #available(iOS 26.0, *) {
                        Capsule()
                            .fill(.clear)
                            .glassEffect(.regular, in: Capsule())
                            .overlay(
                                Capsule()
                                    .fill(tabColor.opacity(0.18)) // jemné tónování pozadí pilulky barvou z Assets
                                    .clipShape(Capsule())
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(tabColor.opacity(0.22), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 10)
                    } else {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .fill(tabColor.opacity(0.16)) // jemné tónování pilulky
                                    .clipShape(Capsule())
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(tabColor.opacity(0.22), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 6)
                    }
                }
            )
            .contentShape(Capsule())
            
            // Separate round glass button (plus)
            RoundGlassButton(size: roundButtonSize, systemImage: "plus", tabColor: tabColor) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                onPlusTapped()
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, 8)
        .tint(tabColor) // použijeme TabColor jako accent/tint
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Capsule Tab Button (icon only + moving glass bubble)
private struct CapsuleTabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let animation: Namespace.ID
    let bubbleSize: CGSize
    let iconSize: CGFloat
    let tabColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    if #available(iOS 26.0, *) {
                        Capsule()
                            .fill(.clear)
                            .glassEffect(.regular, in: Capsule())
                            .overlay(
                                Capsule()
                                    .fill(tabColor.opacity(0.22))
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(tabColor.opacity(0.35), lineWidth: 1)
                            )
                            .frame(width: bubbleSize.width, height: bubbleSize.height)
                            .matchedGeometryEffect(id: "selectedTabBubble", in: animation)
                            .animation(.interpolatingSpring(stiffness: 560, damping: 34), value: isSelected)
                    } else {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .fill(tabColor.opacity(0.20))
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(tabColor.opacity(0.35), lineWidth: 1)
                            )
                            .frame(width: bubbleSize.width, height: bubbleSize.height)
                            .matchedGeometryEffect(id: "selectedTabBubble", in: animation)
                            .animation(.interpolatingSpring(stiffness: 560, damping: 34), value: isSelected)
                    }
                }
                
                Image(systemName: isSelected ? (tab.selectedIcon ?? tab.icon) : tab.icon)
                    .font(.system(size: iconSize, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? tabColor : .white)
                    .scaleEffect(isSelected ? 1.06 : 1.0)
                    .animation(.interpolatingSpring(stiffness: 480, damping: 28), value: isSelected)
                    .contentTransition(.symbolEffect(.replace))
            }
            .frame(maxWidth: .infinity, minHeight: bubbleSize.height)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(tab.title))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Separate Round Glass Button
private struct RoundGlassButton: View {
    let size: CGFloat
    let systemImage: String
    let tabColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if #available(iOS 26.0, *) {
                    Circle()
                        .fill(.clear)
                        .glassEffect(.regular, in: Circle())
                        .overlay(
                            Circle()
                                .fill(tabColor.opacity(0.20)) // tónování kruhu TabColor
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(tabColor.opacity(0.28), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 10)
                } else {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .fill(tabColor.opacity(0.18))
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(tabColor.opacity(0.28), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 6)
                }
                
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Main Content View with Floating Navigation (Fallback for iOS < 26)
struct MainContentView<Content: View>: View {
    @State private var selectedTab: Int = 0
    @State private var showPlusSheet: Bool = false
    let tabs: [TabItem]
    let content: (Int, @escaping (Int) -> Void) -> Content
    
    init(tabs: [TabItem], @ViewBuilder content: @escaping (Int, @escaping (Int) -> Void) -> Content) {
        self.tabs = tabs
        self.content = content
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ZStack {
                ForEach(0..<tabs.count, id: \.self) { index in
                    content(index, { newIndex in
                        withAnimation(.interpolatingSpring(stiffness: 520, damping: 32)) {
                            selectedTab = newIndex
                        }
                    })
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(selectedTab == index ? 1 : 0)
                        .scaleEffect(selectedTab == index ? 1 : 0.985)
                        .offset(y: selectedTab == index ? 0 : 10)
                        .animation(.interpolatingSpring(stiffness: 360, damping: 32), value: selectedTab)
                        .zIndex(selectedTab == index ? 1 : 0)
                }
            }
        }
        // Bottom accessory mimic for iOS < 26: show everywhere except Home (index 0)
        .overlay(alignment: .bottom) {
            if selectedTab != 0 {
                MonthlySpentAccessory()
                    .padding(.horizontal, 24) // align with bar's outer horizontal padding
                    .padding(.bottom, 78) // slightly closer to the bar for a more iOS-like feel
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.36, dampingFraction: 0.86), value: selectedTab)
            }
        }
        .overlay(alignment: .bottom) {
            ModernBottomNavigationBar(selectedTab: $selectedTab, tabs: tabs, onPlusTapped: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showPlusSheet = true
            })
        }
        .sheet(isPresented: $showPlusSheet) {
            PlusQuickActionsSheet(
                onAddManual: {
                    // Např. přepnout na tab "Přidat" nebo otevřít AddView
                    selectedTab = 1
                    showPlusSheet = false
                },
                onScanBarcode: {
                    // TODO: Napojit skener
                    showPlusSheet = false
                },
                onRecognizeImage: {
                    // TODO: Napojit rozpoznávání
                    showPlusSheet = false
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
        }
    }
}

// MARK: - iOS 26+ Native Tab Container
@available(iOS 26.0, *)
struct iOS26TabContainer: View {
    @State private var selectedTab: Int = 0
    @State private var lastNonPlusTab: Int = 0
    @State private var showPlusSheet: Bool = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Domů", systemImage: "house", value: 0) {
                HomeView(onOpenHistory: { selectedTab = 2 })
                    .tag(0)
            }
            Tab("Historie", systemImage: "clock", value: 2) {
                HistoryView()
                    .tag(2)
            }
            Tab("Předplatné", systemImage: "calendar", value: 3) {
                SubscriptionView()
                    .tag(3)
            }
            Tab("Profil", systemImage: "person", value: 4) {
                ProfileView()
                    .tag(4)
            }
            // Volitelný systémově oddělený Search tab -> používáme jako „Plus“ spouštěč sheetu
            Tab("Hledat", systemImage: "plus", value: 5, role: .search) {
                // Prázdný obsah, nikdy se nezobrazí – tap vyvolá sheet a výběr vrátíme zpět
                EmptyView()
                    .tag(5)
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            if newValue == 5 {
                // Uživatel tapnul na „plus“ tab: otevři sheet a vrať tab zpět
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showPlusSheet = true
                // Vrátíme vybraný tab zpět na poslední skutečný (aby UI nepřeskočilo)
                selectedTab = lastNonPlusTab
            } else {
                // Uložíme si poslední skutečný tab (mimo plus)
                lastNonPlusTab = newValue
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        // Integrace accessory při sbalení tab baru během scrollu
        .tabBarMinimizeBehavior(.onScrollDown)
        .toolbarBackground(Color("TabColor"), for: .tabBar) // Pozadí tabbaru z Assets
        .toolbarBackground(.visible, for: .tabBar)
        .tint(Color("TabColor")) // zvýraznění aktivní ikony a dalších akcentů
        // Native bottom accessory: show on all tabs except Home (index 0)
        .tabViewBottomAccessory {
            if selectedTab != 0 {
                MonthlySpentAccessory()
                    .padding(.horizontal, 14)
                    .padding(.top, 6)
            }
        }
        .sheet(isPresented: $showPlusSheet) {
            PlusQuickActionsSheet(
                onAddManual: {
                    selectedTab = 1 // přepnout na „Přidat“ tab (pokud ho v iOS26 používáš)
                    showPlusSheet = false
                },
                onScanBarcode: {
                    showPlusSheet = false
                },
                onRecognizeImage: {
                    showPlusSheet = false
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
        }
    }
}

// MARK: - Monthly Spent Accessory (icon left, bigger amount right, full width)
struct MonthlySpentAccessory: View {
    @EnvironmentObject var finance: FinanceStore
    
    private func formattedAmount(_ value: Decimal, code: String) -> String {
        value.asDouble.formatted(.currency(code: code))
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Left icon
            Image(systemName: "creditcard.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
                .alignmentGuide(.firstTextBaseline) { d in d[.bottom] }
                .offset(y: -3) // optický posun ikonky výš (původně -1)
            
            Spacer(minLength: 10)
            
            // Right amount (slightly larger)
            Text(formattedAmount(finance.monthlySpent, code: finance.currencyCode))
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .alignmentGuide(.firstTextBaseline) { d in d[.bottom] }
                .offset(y: -3) // stejný optický posun jako ikonka
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6) // o něco menší, aby se celý obsah posunul výš v rámci tab baru
        .frame(maxWidth: .infinity, alignment: .trailing)
        .frame(minHeight: 28)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Utraceno tento měsíc")
        .accessibilityValue(formattedAmount(finance.monthlySpent, code: finance.currencyCode))
    }
}

// MARK: - Plus Quick Actions Sheet (inspirace „Najít“)
private struct PlusQuickActionsSheet: View {
    var onAddManual: () -> Void
    var onScanBarcode: () -> Void
    var onRecognizeImage: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ActionRow(title: "Přidat ručně", subtitle: "Zadat částku a detaily", systemImage: "pencil.circle.fill", tint: .blue, action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onAddManual()
                    })
                    ActionRow(title: "Skenovat čárový kód", subtitle: "Rychlé načtení z kódu", systemImage: "barcode.viewfinder", tint: .green, action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onScanBarcode()
                    })
                    ActionRow(title: "Rozpoznat z obrázku", subtitle: "Použít fotoaparát nebo knihovnu", systemImage: "camera.viewfinder", tint: .orange, action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onRecognizeImage()
                    })
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Přidat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Hotovo") { dismiss() }
                }
            }
        }
    }
    
    private struct ActionRow: View {
        let title: String
        let subtitle: String
        let systemImage: String
        let tint: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(tint.opacity(0.18))
                        Image(systemName: systemImage)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(tint)
                    }
                    .frame(width: 44, height: 44)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.body.weight(.semibold))
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title)
            .accessibilityHint(subtitle)
        }
    }
}

// MARK: - Preview
#Preview {
    if #available(iOS 26.0, *) {
        iOS26TabContainer()
            .preferredColorScheme(.dark)
            .environmentObject(FinanceStore())
    } else {
        MainContentView(tabs: TabItem.defaultTabs) { selectedIndex, onSelectTab in
            switch selectedIndex {
            case 0:
                HomeView(onOpenHistory: { onSelectTab(2) })
            case 1:
                AddView()
            case 2:
                HistoryView()
            case 3:
                SubscriptionView()
            case 4:
                ProfileView()
            default:
                HomeView(onOpenHistory: { onSelectTab(2) })
            }
        }
        .preferredColorScheme(.dark)
        .environmentObject(FinanceStore())
    }
}
