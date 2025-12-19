//
//  AppReviewManager.swift
//  MyApp
//
//  Manages App Store review prompts at strategic moments.
//  Follows Apple's best practices for review requests.
//

import StoreKit
@preconcurrency import SwiftUI

/// Manages App Store review requests
///
/// This manager handles requesting app reviews at optimal moments (e.g., after streak achievements).
/// It tracks whether a review has been requested for each threshold to avoid spamming users.
///
/// Usage:
/// ```swift
/// // Check and potentially request review after streak achievement
/// AppReviewManager.shared.requestReviewIfAppropriate(for: streakCount)
/// ```
///
/// The actual review dialog is controlled by Apple's SKStoreReviewController, which may
/// choose not to show the dialog based on its own heuristics (e.g., if shown too recently).
final class AppReviewManager {

    static let shared = AppReviewManager()

    private let reviewRequestedKey = "appReviewRequestedForStreak"

    private init() {}

    // MARK: - Public Methods

    /// Request a review if conditions are met
    ///
    /// Call this when the user achieves a streak milestone. The review will only be requested
    /// if the user has reached the threshold and hasn't been prompted for this threshold before.
    ///
    /// - Parameter streakCount: The user's current streak count
    func requestReviewIfAppropriate(for streakCount: Int) {
        guard AppConfiguration.enableAppReview else { return }
        guard streakCount >= AppConfiguration.appReviewStreakThreshold else { return }
        guard !hasRequestedReviewForCurrentThreshold else { return }

        requestReview()
        markReviewRequested()
    }

    /// Force request a review (use sparingly)
    ///
    /// Bypasses the streak threshold check. Still respects the enableAppReview flag
    /// and won't re-prompt if already prompted for current threshold.
    func requestReviewManually() {
        guard AppConfiguration.enableAppReview else { return }
        guard !hasRequestedReviewForCurrentThreshold else { return }

        requestReview()
        markReviewRequested()
    }

    /// Reset review tracking (useful for testing or after major app updates)
    func resetReviewTracking() {
        UserDefaults.standard.removeObject(forKey: reviewRequestedKey)
    }

    // MARK: - Private Methods

    private var hasRequestedReviewForCurrentThreshold: Bool {
        let requestedThreshold = UserDefaults.standard.integer(forKey: reviewRequestedKey)
        return requestedThreshold >= AppConfiguration.appReviewStreakThreshold
    }

    private func markReviewRequested() {
        UserDefaults.standard.set(
            AppConfiguration.appReviewStreakThreshold,
            forKey: reviewRequestedKey
        )
    }

    private func requestReview() {
        Task { @MainActor in
            // Small delay to ensure we're not interrupting other UI
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {

                // Use modern API on iOS 18+, fallback for iOS 17
                if #available(iOS 18.0, *) {
                    AppStore.requestReview(in: scene)
                } else {
                    SKStoreReviewController.requestReview(in: scene)
                }

                Analytics.track(event: "app_review_requested", parameters: [
                    "streak_threshold": AppConfiguration.appReviewStreakThreshold
                ])
            }
        }
    }
}
