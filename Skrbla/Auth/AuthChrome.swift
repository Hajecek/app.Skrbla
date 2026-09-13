//
//  AuthChrome.swift
//  Skrbla
//
//  Společný vizuál přihlášení / registrace.
//

import SwiftUI

enum AuthFieldFocus: Hashable {
    case name
    case email
    case password
}

struct AuthScreenChrome<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    var appeared: Bool
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                brandBlock
                    .padding(.top, 20)
                    .padding(.horizontal, 28)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -24)
                    .scaleEffect(appeared ? 1 : 0.94)

                Spacer(minLength: 16)

                ScrollView(.vertical, showsIndicators: false) {
                    content()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 22)
                        .padding(.top, 28)
                        .padding(.bottom, 10)
                }
                .scrollDismissesKeyboard(.interactively)
                .frame(maxWidth: .infinity)
                .background(sheetBackground)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 32,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 32,
                        style: .continuous
                    )
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 64)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private var background: some View {
        GeometryReader { geo in
            ZStack {
                // Hluboký brand gradient místo fotky
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.28, blue: 0.24),
                        SkrblaTheme.primaryDeep,
                        Color(red: 0.08, green: 0.42, blue: 0.38),
                        SkrblaTheme.secondaryDeep
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Měkké světelné plochy (mesh)
                Circle()
                    .fill(SkrblaTheme.primary.opacity(0.42))
                    .frame(width: geo.size.width * 0.85)
                    .blur(radius: 55)
                    .offset(
                        x: geo.size.width * 0.28,
                        y: appeared ? -geo.size.height * 0.08 : -geo.size.height * 0.14
                    )

                Circle()
                    .fill(SkrblaTheme.secondary.opacity(0.32))
                    .frame(width: geo.size.width * 0.7)
                    .blur(radius: 60)
                    .offset(
                        x: -geo.size.width * 0.35,
                        y: appeared ? geo.size.height * 0.18 : geo.size.height * 0.24
                    )

                Ellipse()
                    .fill(Color.white.opacity(0.10))
                    .frame(width: geo.size.width * 1.1, height: geo.size.height * 0.34)
                    .blur(radius: 40)
                    .offset(y: -geo.size.height * 0.22)

                AuthWaveOverlay()
                    .opacity(0.55)
                    .blendMode(.plusLighter)
                    .frame(height: geo.size.height * 0.55)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .allowsHitTesting(false)

                // Čitelnost brandu
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.18),
                        .clear,
                        Color.black.opacity(0.28)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .ignoresSafeArea()
            .animation(.easeOut(duration: 1.1), value: appeared)
        }
    }

    private var brandBlock: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(colorScheme == .dark ? "LogoDark" : "Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.22), radius: 16, y: 8)

            VStack(alignment: .leading, spacing: 8) {
                Text("Skrbla")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(-1.2)

                Text("Správa peněz bez zbytečného chaosu.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var sheetBackground: some View {
        ZStack {
            Rectangle()
                .fill(colorScheme == .dark ? Color(red: 0.09, green: 0.11, blue: 0.13) : Color.white)

            // Jemný horní odlesk zeleně – ne glow blob
            LinearGradient(
                colors: [
                    SkrblaTheme.primary.opacity(colorScheme == .dark ? 0.10 : 0.07),
                    .clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

struct AuthTextField: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let systemImage: String
    var isSecure: Bool = false
    @Binding var text: String
    var focus: AuthFieldFocus
    var focusedField: FocusState<AuthFieldFocus?>.Binding
    var contentType: UITextContentType?
    var keyboard: UIKeyboardType = .default
    var submitLabel: SubmitLabel = .next
    var onSubmit: (() -> Void)?

    var body: some View {
        let isFocused = focusedField.wrappedValue == focus

        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.1)
                .foregroundStyle(secondaryLabel)

            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isFocused ? SkrblaTheme.primaryDeep : secondaryLabel)
                    .frame(width: 18)

                Group {
                    if isSecure {
                        SecureField("", text: $text)
                    } else {
                        TextField("", text: $text)
                            .keyboardType(keyboard)
                            .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                            .autocorrectionDisabled(keyboard == .emailAddress)
                    }
                }
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(primaryLabel)
                .textContentType(contentType)
                .focused(focusedField, equals: focus)
                .submitLabel(submitLabel)
                .onSubmit { onSubmit?() }
            }
            .padding(.bottom, 12)
            .overlay(alignment: .bottom) {
                Capsule()
                    .fill(isFocused ? SkrblaTheme.primary : dividerColor)
                    .frame(height: isFocused ? 2 : 1)
                    .animation(.easeInOut(duration: 0.18), value: isFocused)
            }
        }
    }

    private var primaryLabel: Color {
        colorScheme == .dark ? .white : SkrblaTheme.slate
    }

    private var secondaryLabel: Color {
        colorScheme == .dark ? .white.opacity(0.45) : SkrblaTheme.slate.opacity(0.45)
    }

    private var dividerColor: Color {
        colorScheme == .dark ? .white.opacity(0.14) : SkrblaTheme.slate.opacity(0.12)
    }
}

struct AuthPrimaryButton: View {
    let title: String
    var isLoading: Bool
    var isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            action()
        } label: {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        isEnabled
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [SkrblaTheme.primary, SkrblaTheme.secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(SkrblaTheme.primary.opacity(0.38))
                    )
            )
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// MARK: - Animované vlnky pro auth pozadí

private struct AuthWaveOverlay: View {
    private let waveCount = 14

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let phase = time * 0.42
                let amplitude: CGFloat = 18
                let topY: CGFloat = 20
                let bottomY = size.height * 0.92
                let spacing = (bottomY - topY) / CGFloat(max(waveCount - 1, 1))

                for i in 0..<waveCount {
                    var path = Path()
                    let yBase = topY + CGFloat(i) * spacing
                    let safeWidth = max(size.width, 1)
                    path.move(to: CGPoint(x: -20, y: yBase))

                    var x: CGFloat = -20
                    while x <= size.width + 30 {
                        let normalized = Double(x / safeWidth)
                        let y = yBase + CGFloat(sin(normalized * .pi * 2.4 + phase + Double(i) * 0.12)) * amplitude
                        path.addLine(to: CGPoint(x: x, y: y))
                        x += 6
                    }

                    let fade = 1 - CGFloat(i) / CGFloat(max(waveCount - 1, 1))
                    let alpha = 0.04 + fade * 0.10
                    context.stroke(path, with: .color(.white.opacity(alpha)), lineWidth: 1.1)
                }
            }
        }
    }
}
