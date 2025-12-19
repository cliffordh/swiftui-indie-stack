//
//  MyApp.swift
//  MyApp
//
//  Main app entry point with conditional Firebase, RevenueCat, and TelemetryDeck initialization.
//

import SwiftUI

#if canImport(RevenueCat)
import RevenueCat
#endif

#if canImport(TelemetryDeck)
import TelemetryDeck
#endif

#if canImport(Firebase)
import Firebase
import FirebaseCrashlytics
#endif

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @AppStorage("isOnboardingDone") private var isOnboardingDone = false
    @StateObject private var authManager = AuthManager.shared

    init() {
        // Skip initialization in SwiftUI previews
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }

        // Initialize auth (Firebase or local depending on config)
        if AppConfiguration.useFirebase {
            Task { @MainActor in
                await AuthManager.shared.handleInitialAuthentication()
            }
        }

        // Configure RevenueCat (if enabled)
        if AppConfiguration.useRevenueCat {
            #if canImport(RevenueCat)
            Purchases.logLevel = .info
            Purchases.configure(withAPIKey: AppConfiguration.revenueCatAPIKey)

            // Set TelemetryDeck attributes in RevenueCat for integration
            if AppConfiguration.useTelemetryDeck {
                let defaultUserID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_user"
                Purchases.shared.attribution.setAttributes([
                    "$telemetryDeckUserId": defaultUserID,
                    "$telemetryDeckAppId": AppConfiguration.telemetryDeckAppID
                ])
            }
            #endif
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isOnboardingDone {
                    MainTabView()
                        .modifier(DarkModeViewModifier())
                } else {
                    OnboardingView(isOnboardingDone: $isOnboardingDone)
                }
            }
            .environmentObject(authManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Skip initialization in SwiftUI previews
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return true
        }

        // Initialize TelemetryDeck (if enabled)
        if AppConfiguration.useTelemetryDeck {
            #if canImport(TelemetryDeck)
            let config = TelemetryDeck.Config(appID: AppConfiguration.telemetryDeckAppID)
            TelemetryDeck.initialize(config: config)
            TelemetryDeck.signal("app_launch", parameters: ["launch_type": "cold"])
            #endif
        }

        // Initialize Firebase (if enabled)
        if AppConfiguration.useFirebase {
            #if canImport(Firebase)
            FirebaseApp.configure()

            #if DEBUG
            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
            #else
            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
            Crashlytics.crashlytics().setCustomValue(deviceId, forKey: "device_id")
            Crashlytics.crashlytics().log("App launched successfully")
            #endif
            #endif
        }

        // Setup notification handling
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    // MARK: - Notification Handling

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let notificationIdentifier = response.notification.request.identifier

        Analytics.track(event: "notification.opened", parameters: ["type": notificationIdentifier])

        // Handle specific notification types here
        // Example:
        // let userInfo = response.notification.request.content.userInfo
        // if let action = userInfo["action"] as? String { ... }

        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}
