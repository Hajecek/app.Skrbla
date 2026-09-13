//
//  SettingsView.swift
//  Skrbla
//

import SwiftUI

private enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "Systém"
        case .light: return "Světlý"
        case .dark: return "Tmavý"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var financeStore: FinanceStore
    @EnvironmentObject private var appDelegate: AppDelegate
    @AppStorage("settings.appearance.mode") private var appearanceRaw: String = AppearanceMode.system.rawValue
    @AppStorage("settings.notifications.general") private var notificationsGeneral = true
    @State private var budgetText = ""
    @State private var showClearConfirm = false

    private var appearance: AppearanceMode {
        AppearanceMode(rawValue: appearanceRaw) ?? .system
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "Verze \(version) (\(build))"
    }

    var body: some View {
        Form {
            Section {
                Picker(
                    selection: Binding(
                        get: { appearance },
                        set: { appearanceRaw = $0.rawValue }
                    )
                ) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                } label: {
                    Label("Režim vzhledu", systemImage: "circle.lefthalf.filled")
                }
            } header: {
                Text("Vzhled")
            }

            Section {
                Toggle(isOn: Binding(
                    get: { notificationsGeneral },
                    set: { enabled in
                        notificationsGeneral = enabled
                        if enabled {
                            appDelegate.requestNotificationPermission()
                        }
                    }
                )) {
                    Label("Obecná oznámení", systemImage: "bell")
                }

                Button {
                    appDelegate.preparePushNotifications()
                } label: {
                    Label("Obnovit FCM token", systemImage: "arrow.clockwise")
                }

                if let token = appDelegate.fcmToken {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FCM token")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(token)
                            .font(.system(.caption2, design: .monospaced))
                            .textSelection(.enabled)
                        Button {
                            UIPasteboard.general.string = token
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } label: {
                            Label("Zkopírovat token", systemImage: "doc.on.doc")
                        }
                    }
                } else {
                    Text("Token zatím není – povol notifikace a spusť appku na reálném iPhonu.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Oznámení")
            } footer: {
                Text("Push funguje s reálným APNS tokenem (fyzické zařízení). Token zkopíruj do Firebase Console → Messaging → Send test message.")
            }

            Section {
                TextField("Měsíční rozpočet (Kč)", text: $budgetText)
                    .keyboardType(.decimalPad)
                Button("Uložit rozpočet") {
                    let normalized = budgetText.replacingOccurrences(of: ",", with: ".")
                    if let value = Double(normalized), value > 0 {
                        financeStore.monthlyBudget = value
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                }
            } header: {
                Text("Rozpočet")
            }

            Section {
                Button("Vymazat lokální data", role: .destructive) {
                    showClearConfirm = true
                }
            } header: {
                Text("Data")
            } footer: {
                Text("Smaže výdaje a předplatná uložená v zařízení. SQL backend zatím není.")
            }

            Section {
                LabeledContent("Aplikace", value: "Skrbla")
                LabeledContent("Úložiště", value: "Lokální (UserDefaults)")
                LabeledContent("", value: appVersion)
            } header: {
                Text("O aplikaci")
            }
        }
        .navigationTitle("Nastavení")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            budgetText = String(format: "%.0f", financeStore.monthlyBudget)
            appDelegate.preparePushNotifications()
        }
        .alert("Vymazat všechna lokální data?", isPresented: $showClearConfirm) {
            Button("Vymazat", role: .destructive) {
                financeStore.clearAllData()
            }
            Button("Zrušit", role: .cancel) {}
        } message: {
            Text("Tato akce nejde vrátit.")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(FinanceStore.shared)
    .environmentObject(AppDelegate())
}
