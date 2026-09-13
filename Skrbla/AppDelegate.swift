//
//  AppDelegate.swift
//  Skrbla
//
//  Push jako Provikart: FCM token se bere až PO reálném APNS tokenu.
//

import FirebaseCore
import FirebaseMessaging
import SwiftUI
import UserNotifications

private let onboardingCompletedKey = "Skrbla.hasCompletedOnboarding"
private let notificationsEnabledKey = "Skrbla.notificationsEnabled"

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate, ObservableObject {
    @Published var fcmToken: String?

    private var lastPrintedToken: String?
    private var hasRealAPNSToken = false

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            return true
        }

        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        if UserDefaults.standard.bool(forKey: onboardingCompletedKey) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .authorized
                        || settings.authorizationStatus == .provisional
                        || settings.authorizationStatus == .ephemeral {
                        UserDefaults.standard.set(true, forKey: notificationsEnabledKey)
                        application.registerForRemoteNotifications()
                    }
                }
            }
        }

        return true
    }

    func preparePushNotifications(application: UIApplication = .shared) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    UserDefaults.standard.set(true, forKey: notificationsEnabledKey)
                    application.registerForRemoteNotifications()
                case .notDetermined:
                    self?.requestNotificationPermission()
                case .denied:
                    UserDefaults.standard.set(false, forKey: notificationsEnabledKey)
                @unknown default:
                    break
                }
            }
        }
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Stejně jako Provikart – nejdřív APNS, teprve pak FCM token.
        Messaging.messaging().apnsToken = deviceToken
        hasRealAPNSToken = true
        lastPrintedToken = nil

        // Po navázání APNS vždy znovu načti FCM token (ten dřívější bez APNS push nedoručí).
        Messaging.messaging().token { [weak self] token, error in
            DispatchQueue.main.async {
                guard error == nil else { return }
                self?.fcmToken = token
                self?.printTokenOnce(token)
                self?.subscribeToAllUsers()
            }
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        hasRealAPNSToken = false
    }

    func subscribeToAllUsers() {
        Messaging.messaging().subscribe(toTopic: "all_users") { _ in }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        NotificationCenter.default.post(
            name: Notification.Name("didReceiveRemoteNotification"),
            object: nil,
            userInfo: userInfo as? [String: Any]
        )
        completionHandler([.banner, .list, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(
            name: Notification.Name("didReceiveRemoteNotification"),
            object: nil,
            userInfo: userInfo as? [String: Any]
        )
        completionHandler()
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        NotificationCenter.default.post(
            name: Notification.Name("didReceiveRemoteNotification"),
            object: nil,
            userInfo: userInfo as? [String: Any]
        )
        completionHandler(.newData)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Nevypsat token bez APNS – ten z Firebase Console nedoručí notifikaci.
        guard hasRealAPNSToken, Messaging.messaging().apnsToken != nil else { return }
        DispatchQueue.main.async {
            self.fcmToken = fcmToken
            self.printTokenOnce(fcmToken)
        }
    }

    func refreshFCMToken() {
        guard hasRealAPNSToken, Messaging.messaging().apnsToken != nil else {
            UIApplication.shared.registerForRemoteNotifications()
            return
        }
        lastPrintedToken = nil
        Messaging.messaging().token { [weak self] token, error in
            DispatchQueue.main.async {
                guard error == nil else { return }
                self?.fcmToken = token
                self?.printTokenOnce(token)
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                UserDefaults.standard.set(granted, forKey: notificationsEnabledKey)
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    private func printTokenOnce(_ token: String?) {
        guard let token, !token.isEmpty, token != lastPrintedToken else { return }
        lastPrintedToken = token
        print(token)
    }
}
