//
//  SessionUnlockState.swift
//  Skrbla
//

import Foundation
import SwiftUI

final class SessionUnlockState: ObservableObject {
    @Published private(set) var isUnlocked: Bool = false

    func unlock() {
        isUnlocked = true
    }

    func lock() {
        isUnlocked = false
    }
}

private struct SessionUnlockedKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var sessionUnlocked: Bool {
        get { self[SessionUnlockedKey.self] }
        set { self[SessionUnlockedKey.self] = newValue }
    }
}
