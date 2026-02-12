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
    
    // Lokální barva: bílá (nepoužíváme TabColor z Assets)
    private var tabColor: Color { .white }
    
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
                        // Index 1 je "add" tlačítko - otevři sheet místo změny tabu
                        if index == 1 {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            onPlusTapped()
                        } else {
                            withAnimation(.interpolatingSpring(stiffness: 520, damping: 32)) {
                                selectedTab = index
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
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
                                    .fill(tabColor.opacity(0.18)) // jemné tónování pozadí pilulky bílou
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
                                    .fill(tabColor.opacity(0.16)) // jemné tónování pozadí pilulky bílou
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
        .tint(tabColor) // bílá jako accent/tint pro bar
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
                                .fill(tabColor.opacity(0.20)) // tónování kruhu bílou
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
    @State private var lastNonPlusTab: Int = 0
    @State private var showPlusSheet: Bool = false
    @State private var showManualAdd: Bool = false
    @State private var showVoiceAdd: Bool = false
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
        .onChange(of: selectedTab) { _, newValue in
            if newValue == 1 {
                // Index 1 je "add" tlačítko - otevři sheet a vrať tab zpět
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showPlusSheet = true
                // Vrátíme vybraný tab zpět na poslední skutečný (aby UI nepřeskočilo)
                selectedTab = lastNonPlusTab
            } else {
                // Uložíme si poslední skutečný tab (mimo plus)
                lastNonPlusTab = newValue
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
                    // Otevřít ruční přidání v plné obrazovce
                    showPlusSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        showManualAdd = true
                    }
                },
                onScanBarcode: {
                    // TODO: Napojit skener
                    showPlusSheet = false
                },
                onVoiceInput: {
                    showPlusSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        showVoiceAdd = true
                    }
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(46)
            .interactiveDismissDisabled(false)
            .applySheetBackgroundIfAvailable()
        }
        .fullScreenCover(isPresented: $showManualAdd) {
            ManualAddView(
                onContinue: { _ in
                    // TODO: zpracování částky a návrat
                    showManualAdd = false
                },
                onClose: {
                    showManualAdd = false
                }
            )
            .preferredColorScheme(.dark)
        }
        .fullScreenCover(isPresented: $showVoiceAdd) {
            AddScreenTestView()
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - iOS 26+ Native Tab Container
@available(iOS 26.0, *)
struct iOS26TabContainer: View {
    @State private var selectedTab: Int = 0
    @State private var lastNonPlusTab: Int = 0
    @State private var showPlusSheet: Bool = false
    @State private var showManualAdd: Bool = false
    @State private var showVoiceAdd: Bool = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Domů", systemImage: "house", value: 0) {
                HomeView()
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
            // Volitelný systémově oddělený Search tab -> používáme jako „Plus" spouštěč sheetu
            Tab("Hledat", systemImage: "plus", value: 1, role: .search) {
                // Prázdný obsah, nikdy se nezobrazí – tap vyvolá sheet a výběr vrátíme zpět
                EmptyView()
                    .tag(1)
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            if newValue == 1 {
                // Uživatel tapnul na „plus" tab: otevři sheet a vrať tab zpět
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
        // Lokální bílé zvýraznění pro tab bar
        .toolbarBackground(.clear, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .tint(.white)
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
                    showPlusSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        showManualAdd = true
                    }
                },
                onScanBarcode: {
                    showPlusSheet = false
                },
                onVoiceInput: {
                    showPlusSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        showVoiceAdd = true
                    }
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(46)
            .interactiveDismissDisabled(false)
            .applySheetBackgroundIfAvailable()
        }
        .fullScreenCover(isPresented: $showManualAdd) {
            ManualAddView(
                onContinue: { _ in
                    showManualAdd = false
                },
                onClose: {
                    showManualAdd = false
                }
            )
            .preferredColorScheme(.dark)
        }
        .fullScreenCover(isPresented: $showVoiceAdd) {
            AddScreenTestView()
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Monthly Spent Accessory (disabled – FinanceStore removed)
struct MonthlySpentAccessory: View {
    var body: some View {
        // Prázdné, protože FinanceStore byl odstraněn
        EmptyView()
    }
}

// MARK: - Plus Quick Actions Sheet – kompletně přepracovaný iOS-like design
private struct PlusQuickActionsSheet: View {
    var onAddManual: () -> Void
    var onScanBarcode: () -> Void
    var onVoiceInput: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var hSize
    
    private var gridColumns: [GridItem] {
        // iPhone: 2 sloupce, širší obrazovky: 3
        let count = (hSize == .regular) ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Primární doporučená akce (full-width)
                    PrimaryActionCard(
                        title: "Přidat ručně",
                        subtitle: "Zadat částku a detaily",
                        systemImage: "square.and.pencil",
                        tint: .blue
                    ) {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onAddManual()
                    }
                    .accessibilityAddTraits(.isButton)
                    
                    // Grid sekundárních akcí
                    LazyVGrid(columns: gridColumns, spacing: 12) {
                        ActionCard(
                            title: "Skenovat kód",
                            subtitle: "Načíst částku z čárového kódu",
                            systemImage: "barcode.viewfinder",
                            tint: .green
                        ) {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            onScanBarcode()
                        }
                        .accessibilityAddTraits(.isButton)
                        
                        ActionCard(
                            title: "Zadat hlasem",
                            subtitle: "Diktujte částku a poznámku",
                            systemImage: "mic.fill",
                            tint: .orange
                        ) {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            onVoiceInput()
                        }
                        .accessibilityAddTraits(.isButton)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .navigationTitle("Přidat položku")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Zrušit", role: .cancel) {
                        dismiss()
                    }
                    .accessibilityHint("Zavřít panel bez akce")
                }
            }
        }
    }
    
    // MARK: - Building Blocks
    
    private struct PrimaryActionCard: View {
        let title: String
        let subtitle: String
        let systemImage: String
        let tint: Color
        let action: () -> Void
        
        @State private var pressed = false
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 14) {
                    IconBadge(systemImage: systemImage, tint: tint, size: 52, symbolSize: 26)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.thinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.6)
                        )
                )
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                .scaleEffect(pressed ? 0.98 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: pressed)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in pressed = true }
                    .onEnded { _ in pressed = false }
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title)
            .accessibilityHint(subtitle)
        }
    }
    
    private struct ActionCard: View {
        let title: String
        let subtitle: String
        let systemImage: String
        let tint: Color
        let action: () -> Void
        
        @State private var pressed = false
        
        var body: some View {
            Button(action: action) {
                VStack(alignment: .leading, spacing: 12) {
                    IconBadge(systemImage: systemImage, tint: tint, size: 48, symbolSize: 22)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Text(subtitle)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.thinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.6)
                        )
                )
                .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
                .scaleEffect(pressed ? 0.98 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: pressed)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in pressed = true }
                    .onEnded { _ in pressed = false }
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title)
            .accessibilityHint(subtitle)
        }
    }
    
    private struct IconBadge: View {
        let systemImage: String
        let tint: Color
        let size: CGFloat
        let symbolSize: CGFloat
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.16))
                Image(systemName: systemImage)
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: symbolSize, weight: .semibold))
                    .foregroundStyle(tint)
            }
            .frame(width: size, height: size)
            .accessibilityHidden(true)
        }
    }
}

// MARK: - Preview
#Preview {
    if #available(iOS 26.0, *) {
        iOS26TabContainer()
            .preferredColorScheme(.dark)
    } else {
        MainContentView(tabs: TabItem.defaultTabs) { selectedIndex, onSelectTab in
            switch selectedIndex {
            case 0:
                HomeView()
            case 1:
                // Index 1 je "add" tlačítko - otevírá sheet, ne view
                EmptyView()
            case 2:
                HistoryView()
            case 3:
                SubscriptionView()
            case 4:
                ProfileView()
            default:
                HomeView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Sheet background helper
private extension View {
    @ViewBuilder
    func applySheetBackgroundIfAvailable() -> some View {
        if #available(iOS 17.0, *) {
            self.presentationBackground(.regularMaterial)
        } else {
            self
        }
    }
}
