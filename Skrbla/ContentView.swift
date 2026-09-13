//
//  ContentView.swift
//  Skrbla
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authState: AuthState

    var body: some View {
        Group {
            if authState.isLoggedIn {
                TabMenuView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthState())
}
