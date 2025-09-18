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
    static let profile = TabItem(title: "Profil", icon: "person", selectedIcon: "person.fill")
    
    static let defaultTabs: [TabItem] = [.home, .add, .history, .profile]
}

// MARK: - Floating Navigation Bar (Capsule) + Separate Round Button
struct ModernBottomNavigationBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
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
                        iconSize: iconSize
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
                                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 10)
                    } else {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 6)
                    }
                }
            )
            .contentShape(Capsule())
            
            // Separate round glass button (plus)
            RoundGlassButton(size: roundButtonSize, systemImage: "plus") {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, 8)
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    if #available(iOS 26.0, *) {
                        Capsule()
                            .fill(.clear)
                            .glassEffect(.regular, in: Capsule())
                            .tint(.accentColor)
                            .frame(width: bubbleSize.width, height: bubbleSize.height)
                            .matchedGeometryEffect(id: "selectedTabBubble", in: animation)
                            .animation(.interpolatingSpring(stiffness: 560, damping: 34), value: isSelected)
                    } else {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
                            )
                            .frame(width: bubbleSize.width, height: bubbleSize.height)
                            .matchedGeometryEffect(id: "selectedTabBubble", in: animation)
                            .animation(.interpolatingSpring(stiffness: 560, damping: 34), value: isSelected)
                    }
                }
                
                Image(systemName: isSelected ? (tab.selectedIcon ?? tab.icon) : tab.icon)
                    .font(.system(size: iconSize, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .accentColor : .white)
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
                                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 10)
                } else {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
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
        .overlay(alignment: .bottom) {
            ModernBottomNavigationBar(selectedTab: $selectedTab, tabs: tabs)
        }
    }
}

// MARK: - iOS 26+ Native Tab Container
@available(iOS 26.0, *)
struct iOS26TabContainer: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Domů", systemImage: "house", value: 0) {
                HomeView(onOpenHistory: { selectedTab = 2 })
                    .tag(0)
            }
            Tab("Historie", systemImage: "clock", value: 2) {
                HistoryView()
                    .tag(1)
            }
            Tab("Profil", systemImage: "person", value: 3) {
                ProfileView()
                    .tag(2)
            }
            // Volitelný systémově oddělený Search tab (smazat, pokud ho nechceš)
            Tab("Hledat", systemImage: "plus", value: 4, role: .search) {
                ProfileView()
                    .tag(3)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabBarMinimizeBehavior(.onScrollDown)
        // Accessory (container nad tabem) byl kompletně odstraněn
    }
}

// MARK: - Search Accessory Button (right-aligned lupa)
// Ponecháno zde jen pro případné budoucí použití mimo accessory.
// Pokud ho nechceš vůbec, můžeš smazat i tento typ.
struct SearchAccessoryButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(10)
                .background(
                    Group {
                        if #available(iOS 26.0, *) {
                            Circle()
                                .fill(.clear)
                                .glassEffect(.regular, in: Circle())
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 10)
                        } else {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 6)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Hledat")
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
                HomeView(onOpenHistory: { onSelectTab(2) })
            case 1:
                AddView()
            case 2:
                HistoryView()
            case 3:
                ProfileView()
            default:
                HomeView(onOpenHistory: { onSelectTab(2) })
            }
        }
        .preferredColorScheme(.dark)
    }
}
