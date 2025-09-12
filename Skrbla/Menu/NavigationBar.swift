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
    // Titulky ponechávám pro případ budoucího použití, ale v UI se neukazují
    static let home = TabItem(title: "Pusťte si", icon: "house", selectedIcon: "house.fill")
    static let add = TabItem(title: "Rádio", icon: "dot.radiowaves.left.and.right", selectedIcon: "dot.radiowaves.left.and.right")
    static let history = TabItem(title: "Knihovna", icon: "music.note.list", selectedIcon: "music.note.list")
    static let profile = TabItem(title: "Profil", icon: "person", selectedIcon: "person.fill")
    
    static let defaultTabs: [TabItem] = [.home, .add, .history, .profile]
}

// MARK: - Floating Navigation Bar with Liquid Glass Effect (Pill + Separate Round Button)
struct ModernBottomNavigationBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    @Namespace private var animation
    
    // Layout constants tuned to match the reference style (icons only)
    private let barCorner: CGFloat = 30
    private let barHeight: CGFloat = 68
    private let bubbleCorner: CGFloat = 18
    private let bubbleSize: CGSize = CGSize(width: 56, height: 56)
    private let iconSize: CGFloat = 22
    private let tabSpacing: CGFloat = 0
    private let pillHorizontalPadding: CGFloat = 10
    private let pillVerticalPadding: CGFloat = 6
    private let externalSpacing: CGFloat = 12 // spacing between pill and round button
    private let roundButtonSize: CGFloat = 64
    
    var body: some View {
        HStack(spacing: externalSpacing) {
            // Main pill container with tabs
            HStack(spacing: tabSpacing) {
                ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                    PillTabButton(
                        tab: tab,
                        isSelected: selectedTab == index,
                        animation: animation,
                        bubbleCorner: bubbleCorner,
                        bubbleSize: bubbleSize,
                        iconSize: iconSize
                    ) {
                        withAnimation(.interpolatingSpring(stiffness: 520, damping: 32)) {
                            selectedTab = index
                        }
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, pillHorizontalPadding)
            .padding(.vertical, pillVerticalPadding)
            .frame(height: barHeight)
            .background(
                Group {
                    if #available(iOS 26.0, *) {
                        RoundedRectangle(cornerRadius: barCorner, style: .continuous)
                            .fill(.clear)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: barCorner, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: barCorner, style: .continuous)
                                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 10)
                    } else {
                        RoundedRectangle(cornerRadius: barCorner, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: barCorner, style: .continuous)
                                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 6)
                    }
                }
            )
            .contentShape(RoundedRectangle(cornerRadius: barCorner, style: .continuous))
            
            // Separate round glass button (now "plus")
            RoundGlassButton(size: roundButtonSize, systemImage: "plus") {
                // Placeholder action for plus
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.impactOccurred()
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Pill Tab Button (icon only, with moving glass bubble on selection)
private struct PillTabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let animation: Namespace.ID
    let bubbleCorner: CGFloat
    let bubbleSize: CGSize
    let iconSize: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    if #available(iOS 26.0, *) {
                        RoundedRectangle(cornerRadius: bubbleCorner, style: .continuous)
                            .fill(.clear)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: bubbleCorner, style: .continuous))
                            .tint(.accentColor)
                            .frame(width: bubbleSize.width, height: bubbleSize.height)
                            .matchedGeometryEffect(id: "selectedTabBubble", in: animation)
                            .animation(.interpolatingSpring(stiffness: 560, damping: 34), value: isSelected)
                    } else {
                        RoundedRectangle(cornerRadius: bubbleCorner, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: bubbleCorner, style: .continuous)
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

// MARK: - Main Content View with Floating Navigation
struct MainContentView<Content: View>: View {
    @State private var selectedTab: Int = 0
    let tabs: [TabItem]
    let content: (Int) -> Content
    
    init(tabs: [TabItem], @ViewBuilder content: @escaping (Int) -> Content) {
        self.tabs = tabs
        self.content = content
    }
    
    var body: some View {
        ZStack {
            // Background behind everything
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Content behind the floating bar with animated transitions
            ZStack {
                ForEach(0..<tabs.count, id: \.self) { index in
                    content(index)
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

// MARK: - Preview
#Preview {
    MainContentView(tabs: TabItem.defaultTabs) { selectedIndex in
        switch selectedIndex {
        case 0:
            HomeView()
        case 1:
            AddView()
        case 2:
            HistoryView()
        case 3:
            ProfileView()
        default:
            HomeView()
        }
    }
    .preferredColorScheme(.dark)
}
