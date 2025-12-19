//
//  AppConfiguration.swift
//  MyApp
//
//  Central configuration for the app. Toggle features here.
//

import Foundation

/// Central app configuration
/// Toggle features on/off based on your app's needs
enum AppConfiguration {

    // MARK: - Backend Configuration

    /// Enable Firebase backend (Auth, Firestore, Crashlytics)
    /// When disabled:
    /// - Auth uses local-only mode (no cloud sync)
    /// - Settings stored locally only (UserDefaults)
    /// - Streaks are local-only (no cloud calculation)
    /// - Crashlytics disabled
    ///
    /// When enabled:
    /// - Requires GoogleService-Info.plist
    /// - Requires Firebase project setup
    /// - Settings sync to Firestore
    /// - Streaks calculated by Cloud Functions
    static let useFirebase = false

    /// Enable RevenueCat for subscriptions
    /// When disabled, paywall features are hidden
    static let useRevenueCat = true

    /// Enable TelemetryDeck analytics
    /// Privacy-preserving analytics - no PII collected
    static let useTelemetryDeck = true

    // MARK: - Feature Flags

    /// Enable sign-in UI (Apple/Google Sign-In)
    ///
    /// This flag controls whether users see the sign-in option in Settings.
    /// It is independent of `useFirebase` to support progressive onboarding:
    ///
    /// **Recommended Strategy (Low-Friction Onboarding):**
    /// ```
    /// useFirebase = true, enableAuth = false
    /// ```
    /// - Anonymous Firebase account created automatically on first launch
    /// - Full Firestore sync works (streaks, settings, user data)
    /// - No sign-in UI - users enjoy the app without friction
    /// - Later, enable auth or prompt contextually: "Sign in to save your streak!"
    /// - When user signs in, anonymous account links to real account
    /// - All existing data (streaks, settings) preserved automatically
    ///
    /// **Full Auth from Start:**
    /// ```
    /// useFirebase = true, enableAuth = true
    /// ```
    /// - Sign-in option visible in Settings immediately
    /// - Good for apps where account is core to the experience
    ///
    /// **Local-Only Mode:**
    /// ```
    /// useFirebase = false, enableAuth = false
    /// ```
    /// - No Firebase dependency at all
    /// - Device-based identity for RevenueCat/analytics
    /// - All data stored locally (UserDefaults)
    ///
    /// Note: `enableAuth` requires `useFirebase = true` to function.
    /// If Firebase is disabled, sign-in UI is always hidden regardless of this flag.
    static let enableAuth = false

    /// Enable streak tracking
    /// Works in both local mode (UserDefaults) and Firebase mode (Firestore + Cloud Functions)
    static let enableStreaks = true

    /// Enable the Library/CMS feature
    static let enableLibrary = true

    /// Enable widgets
    static let enableWidgets = true

    /// Enable app review prompts
    ///
    /// When enabled, the app will request an App Store review at strategic moments.
    /// Currently triggers when user achieves a 7-day streak (configurable via `appReviewStreakThreshold`).
    ///
    /// The system (SKStoreReviewController) ultimately decides whether to show the prompt.
    /// Apple limits how often the prompt appears, so calling requestReview() doesn't guarantee
    /// the dialog will show. This is by design to prevent review spam.
    ///
    /// Best practices followed:
    /// - Only prompts once per threshold achievement
    /// - Triggers at a moment of positive achievement
    /// - Doesn't interrupt critical user flows
    static let enableAppReview = true

    /// Streak threshold for triggering app review prompt
    /// User must achieve this streak count before review prompt is requested
    static let appReviewStreakThreshold = 7

    // MARK: - API Keys (Replace with your own)

    /// RevenueCat API Key
    /// Get yours at: https://app.revenuecat.com
    static let revenueCatAPIKey = "YOUR_REVENUECAT_API_KEY"

    /// TelemetryDeck App ID
    /// Get yours at: https://dashboard.telemetrydeck.com
    static let telemetryDeckAppID = "YOUR_TELEMETRYDECK_APP_ID"

    // MARK: - URLs (Replace with your own)

    /// Library content index URL (GitHub raw URL)
    /// Default points to the template's sample content - replace with your own content repo
    static let libraryIndexURL = "https://raw.githubusercontent.com/cliffordh/swiftui-indie-stack/main/content/index.json"

    /// Terms of Service URL
    /// Replace with your actual Terms of Service URL before App Store submission
    static let termsOfServiceURL = "https://github.com/cliffordh/swiftui-indie-stack/blob/main/content/terms.md"

    /// Privacy Policy URL
    /// Replace with your actual Privacy Policy URL before App Store submission
    static let privacyPolicyURL = "https://github.com/cliffordh/swiftui-indie-stack/blob/main/content/privacy.md"

    /// Support Email
    static let supportEmail = "support@yourapp.com"

    // MARK: - App Info

    /// App name displayed in UI
    static let appName = "Your App Name"

    /// App Store ID (for review prompts)
    static let appStoreID = "YOUR_APP_STORE_ID"
}

// MARK: - Convenience Accessors

extension AppConfiguration {

    /// Check if cloud features are available
    static var hasCloudFeatures: Bool {
        useFirebase
    }

    /// Check if monetization is enabled
    static var hasMonetization: Bool {
        useRevenueCat
    }
}
