//
//  ProvisionalAddView.swift
//  Skrbla
//
//  Created by Assistant on 03.11.2025.
//

import SwiftUI

struct ProvisionalAddView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("provisionalAmount") private var provisionalAmount: Int = 0
    
    @State private var inputText: String = ""
    @State private var showInvalidAlert = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.08), in: Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // Vynulovat uloženou částku
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        provisionalAmount = 0
                    } label: {
                        Text("Vynulovat")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.08), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Vynulovat částku")
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Text("Provizorní přidání")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    
                    Text("Zadej částku v Kč (přičte se k uložené)")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    TextField("0", text: $inputText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 64, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .tint(.white)
                        .frame(minWidth: 140)
                        .onAppear {
                            // Vstup nezačíná předvyplněný; přičítáme k uložené hodnotě
                            inputText = ""
                        }
                    
                    Text("CZK")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.horizontal, 24)
                
                VStack(spacing: 12) {
                    Button {
                        saveAndAdd()
                    } label: {
                        Text("Přičíst")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.green, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    // Info o aktuální uložené částce
                    Text("Aktuálně uloženo: \(provisionalAmount) Kč")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .alert("Neplatná částka", isPresented: $showInvalidAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Zadej prosím celé nezáporné číslo (např. 150).")
        }
    }
    
    private func saveAndAdd() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            showInvalidAlert = true
            return
        }
        if let value = Int(trimmed), value >= 0 {
            provisionalAmount += value
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            dismiss()
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            showInvalidAlert = true
        }
    }
}

#Preview {
    ProvisionalAddView()
        .preferredColorScheme(.dark)
}
