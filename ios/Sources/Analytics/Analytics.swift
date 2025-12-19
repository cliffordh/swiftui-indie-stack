//
//  Analytics.swift
//  MyApp
//
//  Privacy-preserving analytics using TelemetryDeck.
//  No PII is collected. All data is aggregated and anonymized.
//

import Foundation
import TelemetryDeck

/// Centralized analytics tracking using TelemetryDeck
final class Analytics {

    static var shared = Analytics()

    private init() {}

    /// Track an analytics event
    /// - Parameters:
    ///   - event: Event name (e.g., "view.HomeScreen", "button.subscribe")
    ///   - parameters: Additional parameters for the event
    static func track(
        event: String,
        parameters: [String: Any] = [:]
    ) {
        // Move analytics tracking to background queue
        DispatchQueue.global(qos: .utility).async {
            // Convert parameters to strings for TelemetryDeck
            var telemetryProperties = [String: String]()
            for (key, value) in parameters {
                telemetryProperties[key] = String(describing: value)
            }

            TelemetryDeck.signal(event, parameters: telemetryProperties)
        }
    }

    // MARK: - Common Events

    /// Track a screen view
    static func trackScreenView(_ screenName: String) {
        track(event: "view.\(screenName)")
    }

    /// Track a button tap
    static func trackButtonTap(_ buttonName: String, on screenName: String? = nil) {
        var params: [String: Any] = ["button": buttonName]
        if let screen = screenName {
            params["screen"] = screen
        }
        track(event: "button.tap", parameters: params)
    }

    /// Track a feature usage
    static func trackFeatureUsed(_ featureName: String) {
        track(event: "feature.\(featureName)")
    }

    /// Track an error
    static func trackError(_ errorType: String, message: String? = nil) {
        var params: [String: Any] = ["type": errorType]
        if let msg = message {
            params["message"] = msg
        }
        track(event: "error", parameters: params)
    }

    /// Track onboarding progress
    static func trackOnboardingStep(_ step: Int, stepName: String) {
        track(event: "onboarding.step", parameters: [
            "step": step,
            "name": stepName
        ])
    }

    /// Track subscription events
    static func trackSubscription(_ action: String) {
        track(event: "subscription.\(action)")
    }
}
