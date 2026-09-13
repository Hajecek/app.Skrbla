//
//  BrandComponents.swift
//  Skrbla
//

import SwiftUI

/// Stejný vzor jako Provikart – profil v systémovém toolbaru (Liquid Glass dodá iOS).
struct ProfileBarButton: View {
    @EnvironmentObject private var authState: AuthState
    private let toolbarAvatarSize: CGFloat = 30

    var body: some View {
        NavigationLink {
            ProfileView()
                .environmentObject(authState)
        } label: {
            UserAvatarView(user: authState.currentUser, size: toolbarAvatarSize, showsBorder: false)
                .clipShape(Circle())
                .frame(width: 44, height: 44, alignment: .center)
                .contentShape(Circle())
                .accessibilityLabel("Profil")
                .accessibilityHidden(true)
        }
        .buttonStyle(.plain)
    }
}

struct UserAvatarView: View {
    let user: LocalUser?
    var size: CGFloat = 44
    var showsBorder: Bool = true

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            SkrblaTheme.primaryDeep,
                            SkrblaTheme.secondary
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(user?.initials ?? "S")
                .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            if showsBorder {
                Circle()
                    .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
            }
        }
    }
}

struct HomeTopArchGlow: View {
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height: CGFloat = 380

            ZStack(alignment: .top) {
                LinearGradient(
                    stops: [
                        .init(color: SkrblaTheme.primary.opacity(0.28), location: 0),
                        .init(color: SkrblaTheme.secondary.opacity(0.16), location: 0.34),
                        .init(color: SkrblaTheme.secondary.opacity(0.07), location: 0.58),
                        .init(color: SkrblaTheme.secondary.opacity(0.02), location: 0.8),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                LinearGradient(
                    colors: [
                        SkrblaTheme.primaryDeep.opacity(0.14),
                        SkrblaTheme.primaryDeep.opacity(0.04),
                        .clear
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            }
            .frame(width: width, height: height)
            .mask {
                HomeTopArchShape()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: .white, location: 0),
                                .init(color: .white, location: 0.45),
                                .init(color: .white.opacity(0.55), location: 0.72),
                                .init(color: .white.opacity(0.15), location: 0.9),
                                .init(color: .clear, location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .frame(width: width, height: height, alignment: .top)
        }
        .frame(height: 380)
    }
}

private struct HomeTopArchShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.58))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.maxY * 0.58),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        path.closeSubpath()
        return path
    }
}

extension View {
    @ViewBuilder
    func homeListSectionSpacing() -> some View {
        if #available(iOS 17.0, *) {
            self.listSectionSpacing(8)
        } else {
            self
        }
    }
}
