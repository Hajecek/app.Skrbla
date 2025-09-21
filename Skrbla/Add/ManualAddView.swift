//
//  TestView.swift
//  Skrbla
//
//  Created by Assistant on 26.08.2025.
//

import SwiftUI
import UIKit

struct AmountInputView: View {
    @State private var rawInput: String = "" // Stores digits and optional decimal separator
    @State private var isFocused: Bool = true
    @State private var amountScale: CGFloat = 1.0
    @State private var fractionalCursor: Int? = nil // 0..2 when after separator, nil otherwise
    @State private var amountIntrinsicSize: CGSize = .zero
    @State private var amountContainerWidth: CGFloat = 0
    var onContinue: (Decimal) -> Void = { _ in }
    var onClose: () -> Void = {}

    private let currencySymbol: String = "Kč"
    private let maxFractionDigits = 2
    private let continueTopSpacing: CGFloat = 48

    private var decimalSeparator: String { Locale.current.decimalSeparator ?? "," }

    private var amountDecimal: Decimal {
        Decimal(string: displayNumberForParsing) ?? 0
    }

    private var displayNumberForParsing: String {
        // Replace locale separator with dot for Decimal initializer robustness
        rawInput.replacingOccurrences(of: decimalSeparator, with: ".")
    }

    private var isZero: Bool { amountDecimal == 0 }

    private var displayAmount: String {
        // Build a display string that shows ",00" after decimal tap
        // and replaces zeros as user types fractional digits.
        let sep = decimalSeparator
        let raw = rawInput
        if raw.isEmpty { return "0" }

        if raw.contains(sep) {
            let comps = raw.split(separator: Character(sep), omittingEmptySubsequences: false)
            let integerPartRaw = comps.first.map(String.init) ?? "0"
            let fractionalRaw = comps.count > 1 ? String(comps[1]) : ""

            let formattedInteger = formatIntegerPart(integerPartRaw.isEmpty ? "0" : integerPartRaw)
            let clampedFraction = String(fractionalRaw.prefix(maxFractionDigits))
            let paddedFraction: String
            if clampedFraction.count >= maxFractionDigits {
                paddedFraction = clampedFraction
            } else {
                paddedFraction = clampedFraction.padding(toLength: maxFractionDigits, withPad: "0", startingAt: 0)
            }
            return formattedInteger + sep + paddedFraction
        } else {
            return formatIntegerPart(raw)
        }
    }

    private func formatIntegerPart(_ value: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = "\u{2009}"
        formatter.decimalSeparator = decimalSeparator
        let number = NSDecimalNumber(string: value)
        return formatter.string(from: number) ?? value
    }

    // Build tokens for per-digit rendering with coloring rules
    // Returns array of (character, color)
    private var digitDisplayTokens: [(String, Color)] {
        let green = isZero ? Color.white : Color.green
        let white = Color.white
        let text = displayAmount
        let sep = decimalSeparator

        // Color rule: integer part and separator as green when amount > 0.
        // Fractional digits: if equals "00" from freshly tapped separator and amount still zero, render them white until user overwrites.
        // Once user types fractional digits or amount > 0, use green.
        var tokens: [(String, Color)] = []
        var pastSeparator = false
        var fractionalIndex = 0

        // Determine how many fractional digits the user již reálně vyplnil
        var typedFractionCount: Int = 0
        if let sepIndex = rawInput.firstIndex(of: Character(sep)) {
            let rawFraction = String(rawInput[rawInput.index(after: sepIndex)...])
            typedFractionCount = min(fractionalCursor ?? min(rawFraction.count, maxFractionDigits), maxFractionDigits)
        }

        for ch in text {
            if String(ch) == sep {
                tokens.append((String(ch), green))
                pastSeparator = true
                continue
            }

            if pastSeparator {
                // Fractional digits: barva vychází z počtu uživatelem vyplněných číslic
                let color: Color = (fractionalIndex < typedFractionCount) ? green : white
                tokens.append((String(ch), color))
                fractionalIndex += 1
            } else {
                tokens.append((String(ch), green))
            }
        }
        return tokens
    }

    // Scale to fit available width (caps the large base font)
    // Scale based on velikost částky (práh: tisíce a výš)
    private var magnitudeScale: CGFloat {
        let integer = NSDecimalNumber(decimal: amountDecimal).intValue
        if integer >= 1_000_000 { return 0.7 }
        if integer >= 100_000 { return 0.8 }
        if integer >= 10_000 { return 0.9 }
        if integer >= 1_000 { return 0.95 }
        return 1.0
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.trailing, 24)
                    .padding(.top, 24)
            }

            VStack(spacing: 0) {
                Spacer()

                // Amount label
                HStack(spacing: 12) {
                    Text(currencySymbol)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(isZero ? .white : Color.green)
                    HStack(spacing: 0) {
                        ForEach(Array(digitDisplayTokens.enumerated()), id: \.offset) { index, token in
                            AnimatedDigitText(text: token.0, color: token.1)
                                .id("digit-\(index)-\(token.0)")
                        }
                    }
                }
                .overlay(
                    HStack(spacing: 12) {
                        Text(currencySymbol)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.clear)
                        HStack(spacing: 0) {
                            ForEach(Array(digitDisplayTokens.enumerated()), id: \.offset) { _, token in
                                Text(token.0)
                                    .font(.system(size: 96, weight: .bold))
                                    .monospacedDigit()
                                    .opacity(0)
                            }
                        }
                    }
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                    .measureSize { amountIntrinsicSize = $0 }
                )
                .scaleEffect(amountScale * magnitudeScale)
                .animation(.spring(response: 0.18, dampingFraction: 0.65), value: amountScale)
                .animation(.spring(response: 0.22, dampingFraction: 0.85), value: magnitudeScale)
                .padding(.bottom, 48)

                // Keypad
                keypad

                // Continue button
                Button(action: {
                    logAmountToConsole()
                    onContinue(amountDecimal)
                }) {
                    Text("Continue")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.green)
                        .clipShape(Capsule())
                        .padding(.horizontal, 24)
                        .padding(.top, continueTopSpacing)
                        .padding(.bottom, 24)
                }
            }
        }
        .onAppear { amountContainerWidth = UIScreen.main.bounds.width - 48 }
    }

    private var keypad: some View {
        VStack(spacing: 28) {
            HStack { keypadButton("1"); keypadButton("2"); keypadButton("3") }
            HStack { keypadButton("4"); keypadButton("5"); keypadButton("6") }
            HStack { keypadButton("7"); keypadButton("8"); keypadButton("9") }
            HStack {
                keypadButton(decimalSeparator)
                keypadButton("0")
                deleteButton
            }
        }
        .padding(.horizontal, 48)
    }

    private func keypadButton(_ label: String) -> some View {
        Button(action: { tap(label) }) {
            Text(label)
                .font(.system(size: 36, weight: .regular))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var deleteButton: some View {
        Button(action: backspace) {
            Image(systemName: "delete.left")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func tap(_ input: String) {
        if input == decimalSeparator {
            guard !rawInput.contains(decimalSeparator) else { return }
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                if rawInput.isEmpty {
                    rawInput = "0" + decimalSeparator + "00"
                } else {
                    rawInput.append(decimalSeparator)
                    rawInput.append("00")
                }
                fractionalCursor = 0
            }
            bumpAmount()
            Haptics.light()
            return
        }

        // digit
        guard input.allSatisfy({ $0.isNumber }) else { return }

        // limit fraction digits
        if let sepIndex = rawInput.firstIndex(of: Character(decimalSeparator)) {
            let integer = String(rawInput[..<sepIndex])
            var fraction = String(rawInput[rawInput.index(after: sepIndex)...])

            if fractionalCursor == nil { fractionalCursor = min(fraction.count, maxFractionDigits) }

            if let cursor = fractionalCursor, cursor < maxFractionDigits {
                // Replace at cursor position (initially 0 -> replaces first 0, then 1 -> replaces second)
                var chars = Array(fraction)
                if cursor < chars.count {
                    chars[cursor] = Character(input)
                } else if chars.count < maxFractionDigits {
                    chars.append(contentsOf: input)
                }
                fraction = String(chars)
                rawInput = integer + decimalSeparator + fraction
                fractionalCursor = min(cursor + 1, maxFractionDigits)
                bumpAmount()
                Haptics.light()
                return
            }

            // If fraction already full, do nothing
            if fraction.count >= maxFractionDigits { return }
        }

        // Avoid leading zeros like 0002 unless after decimal sep
        if rawInput == "0" {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) { rawInput = input }
            bumpAmount()
            Haptics.light()
            return
        }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) { rawInput.append(contentsOf: input) }
        bumpAmount()
        Haptics.light()
    }

    private func backspace() {
        guard !rawInput.isEmpty else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
            _ = rawInput.popLast()
            if rawInput == "0" { rawInput = "" }
            // adjust fractional cursor if editing fraction
            if let sepIndex = rawInput.firstIndex(of: Character(decimalSeparator)) {
                let fraction = String(rawInput[rawInput.index(after: sepIndex)...])
                if !fraction.isEmpty {
                    // If there are trailing placeholder zeros after deletion, move cursor to count of real digits
                    let realTyped = fraction.prefix { $0 != "0" }.count < 0 ? 0 : 0 // placeholder line to keep format
                }
                let fractionCount = fraction.count
                if var cursor = fractionalCursor {
                    cursor = max(0, min(cursor - 1, fractionCount))
                    fractionalCursor = cursor
                } else {
                    fractionalCursor = min(fractionCount, maxFractionDigits)
                }
                if fractionCount == 0 { fractionalCursor = nil }
            } else {
                fractionalCursor = nil
            }
        }
        bumpAmount()
        Haptics.rigid()
    }

    private func bumpAmount() {
        withAnimation(.spring(response: 0.18, dampingFraction: 0.65)) {
            amountScale = 1.08
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                amountScale = 1.0
            }
        }
    }
}

struct AmountInputView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AmountInputView()
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.75), value: configuration.isPressed)
    }
}

// MARK: - Animated digit
private struct AnimatedDigitText: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 96, weight: .bold))
            .monospacedDigit()
            .foregroundColor(color)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .transition(.asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
    }
}

// MARK: - Haptics
private enum Haptics {
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }

    static func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }
}

// MARK: - Logging
private extension AmountInputView {
    func logAmountToConsole() {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "cs_CZ")
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Kč"
        let number = NSDecimalNumber(decimal: amountDecimal)
        let text = formatter.string(from: number) ?? "\(number) Kč"
        // Multiple logging backends for reliability on device and simulator
        print("Částka:", text)
    }
}

// MARK: - Size reader
private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private extension View {
    func measureSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}


