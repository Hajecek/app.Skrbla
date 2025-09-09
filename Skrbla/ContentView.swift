//
//  ContentView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
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
}

#Preview {
    ContentView()
}
