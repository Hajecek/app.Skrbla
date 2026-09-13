//
//  BiometricVerificationView.swift
//  Skrbla
//

import LocalAuthentication
import SwiftUI

struct BiometricVerificationView: View {
    var onSuccess: () -> Void

    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var authState: AuthState
    @State private var isAuthenticating = false
    @State private var isUnlockAnimating = false
    @State private var didReportSuccess = false
    @State private var autoAuthTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    SkrblaTheme.slate,
                    SkrblaTheme.primaryDeep.opacity(0.85),
                    SkrblaTheme.secondaryDeep
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                UserAvatarView(user: authState.currentUser, size: 82)
                    .overlay {
                        Circle().stroke(Color.white.opacity(0.92), lineWidth: 2)
                    }
                    .shadow(color: .black.opacity(0.26), radius: 10, y: 5)

                Text("Hezký den, \(authState.currentUser?.displayName.components(separatedBy: " ").first ?? "uživateli")!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .padding(.horizontal, 24)

                Text("Ověření pro přístup do Skrbla")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))

                Spacer()
            }
        }
        .opacity(isUnlockAnimating ? 0 : 1)
        .scaleEffect(isUnlockAnimating ? 1.04 : 1)
        .blur(radius: isUnlockAnimating ? 7 : 0)
        .animation(.easeInOut(duration: 0.42), value: isUnlockAnimating)
        .onAppear {
            scheduleAutomaticAuthentication(delay: 0.55)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                scheduleAutomaticAuthentication(delay: 0.2)
            }
        }
        .onDisappear {
            autoAuthTask?.cancel()
            autoAuthTask = nil
        }
    }

    private func authenticate() {
        guard !isAuthenticating, !didReportSuccess else { return }

        let context = LAContext()
        var biometricError: NSError?
        var passcodeError: NSError?

        let useBiometrics = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &biometricError)
        let usePasscode = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &passcodeError)
        guard useBiometrics || usePasscode else {
            handleSuccessfulAuthentication()
            return
        }

        isAuthenticating = true
        let policy: LAPolicy = useBiometrics ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication
        context.evaluatePolicy(policy, localizedReason: "Ověřte totožnost pro přístup do aplikace Skrbla.") { success, authError in
            DispatchQueue.main.async {
                isAuthenticating = false
                if success {
                    handleSuccessfulAuthentication()
                } else if let laError = authError as? LAError,
                          laError.code == .notInteractive || laError.code == .userCancel {
                    scheduleAutomaticAuthentication(delay: 0.5)
                } else {
                    scheduleAutomaticAuthentication(delay: 0.75)
                }
            }
        }
    }

    private func handleSuccessfulAuthentication() {
        guard !didReportSuccess else { return }
        didReportSuccess = true
        autoAuthTask?.cancel()
        autoAuthTask = nil
        withAnimation(.easeInOut(duration: 0.42)) {
            isUnlockAnimating = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            onSuccess()
        }
    }

    @MainActor
    private func scheduleAutomaticAuthentication(delay: TimeInterval) {
        guard !didReportSuccess else { return }
        autoAuthTask?.cancel()
        autoAuthTask = Task { @MainActor in
            let delayNs = UInt64(max(0, delay) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: delayNs)
            guard !Task.isCancelled, scenePhase == .active, !didReportSuccess else { return }
            authenticate()
        }
    }
}

#Preview {
    BiometricVerificationView(onSuccess: {})
        .environmentObject(AuthState())
}
