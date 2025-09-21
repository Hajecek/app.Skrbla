//
//  SubscriptionView.swift
//  Skrbla
//
//  Created by Michal Hájek on 21.09.2025.
//

import SwiftUI

struct SubscriptionView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "calendar")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                Text("Předplatné")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                Text("Zde brzy najdeš správu svého předplatného.")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
        }
    }
}

#Preview {
    SubscriptionView()
        .preferredColorScheme(.dark)
}

