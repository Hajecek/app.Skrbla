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
    static let home = TabItem(title: "Domů", icon: "house", selectedIcon: "house.fill")
    static let add = TabItem(title: "Přidat", icon: "plus.circle", selectedIcon: "plus.circle.fill")
    static let history = TabItem(title: "Historie", icon: "clock", selectedIcon: "clock.fill")
    static let profile = TabItem(title: "Profil", icon: "person", selectedIcon: "person.fill")
    
    static let defaultTabs: [TabItem] = [.home, .add, .history, .profile]
}

// MARK: - Floating Navigation Bar with Liquid Glass Effect
struct ModernBottomNavigationBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                FloatingTabButton(
                    tab: tab,
                    isSelected: selectedTab == index,
                    animation: animation
                ) {
                    // iOS-like spring animation with haptic feedback
                    withAnimation(Animation.interpolatingSpring(stiffness: 400, damping: 30)) {
                        selectedTab = index
                    }
                    
                    // iOS-like haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            Group {
                if #available(iOS 26.0, *) {
                    // Use the new glassEffect when available
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.clear)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
                } else {
                    // Fallback: translucent material or blur-like background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                }
            }
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 4)
    }
}

// MARK: - Floating Tab Button with Liquid Glass Effect
struct FloatingTabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background for selected state
                if isSelected {
                    if #available(iOS 26.0, *) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.clear)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
                            .tint(.accentColor)
                            .frame(width: 48, height: 48)
                            .matchedGeometryEffect(id: "selectedTab", in: animation)
                            .scaleEffect(isSelected ? 1.0 : 0.95)
                            .animation(Animation.interpolatingSpring(stiffness: 500, damping: 30), value: isSelected)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
                            )
                            .frame(width: 48, height: 48)
                            .matchedGeometryEffect(id: "selectedTab", in: animation)
                            .scaleEffect(isSelected ? 1.0 : 0.95)
                            .animation(Animation.interpolatingSpring(stiffness: 500, damping: 30), value: isSelected)
                    }
                }
                
                Image(systemName: isSelected ? (tab.selectedIcon ?? tab.icon) : tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .accentColor : .primary)
                    .scaleEffect(isSelected ? 1.08 : 1.0)
                    .animation(Animation.interpolatingSpring(stiffness: 400, damping: 25), value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
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
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Content behind the floating bar with iOS-like animated transitions
            ZStack {
                ForEach(0..<tabs.count, id: \.self) { index in
                    content(index)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(selectedTab == index ? 1 : 0)
                        .scaleEffect(selectedTab == index ? 1 : 0.98)
                        .offset(y: selectedTab == index ? 0 : 10)
                        .animation(Animation.interpolatingSpring(stiffness: 300, damping: 30), value: selectedTab)
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
}
