//
//  AuthState.swift
//  Skrbla
//
//  Globální stav přihlášení – lokálně perzistovaný (bez API).
//

import Foundation
import Combine

final class AuthState: ObservableObject {
    private let loggedInKey = "Skrbla.isLoggedIn"
    private let userKey = "Skrbla.currentUser"

    @Published private(set) var isLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: loggedInKey)
            if !isLoggedIn {
                currentUser = nil
            }
        }
    }

    @Published private(set) var currentUser: LocalUser? {
        didSet {
            if let user = currentUser, let data = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(data, forKey: userKey)
            } else {
                UserDefaults.standard.removeObject(forKey: userKey)
            }
        }
    }

    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: loggedInKey)
        if let data = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(LocalUser.self, from: data) {
            self.currentUser = user
        } else {
            self.currentUser = nil
        }
    }

    func setLoggedIn(_ value: Bool, user: LocalUser? = nil) {
        if let user {
            currentUser = user
        } else if !value {
            currentUser = nil
        }
        isLoggedIn = value
    }

    func logIn(email: String, password: String, name: String? = nil) -> Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanEmail.isEmpty, cleanPassword.count >= 4 else { return false }

        let displayName: String
        if let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            displayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let existing = currentUser, existing.email == cleanEmail {
            displayName = existing.name
        } else {
            displayName = cleanEmail.split(separator: "@").first.map(String.init) ?? "Uživatel"
        }

        let user = LocalUser(name: displayName, email: cleanEmail)
        setLoggedIn(true, user: user)
        return true
    }

    func continueAsGuest() {
        let user = LocalUser(name: "Host", email: "host@skrbla.local")
        setLoggedIn(true, user: user)
    }

    func updateProfile(name: String, email: String) {
        guard var user = currentUser else { return }
        user.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        user.email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        currentUser = user
    }

    func logOut() {
        setLoggedIn(false)
    }
}
