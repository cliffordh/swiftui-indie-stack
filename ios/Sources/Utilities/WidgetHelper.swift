//
//  WidgetHelper.swift
//  MyApp
//
//  Helper to sync streak data to widget extension via App Groups.
//  Call updateWidget() whenever streak data changes.
//

import Foundation
import WidgetKit

/// Syncs streak data to home screen and lock screen widgets
struct WidgetHelper {

    // IMPORTANT: This must match the App Group identifier in:
    // 1. Main app target -> Signing & Capabilities -> App Groups
    // 2. Widget extension target -> Signing & Capabilities -> App Groups
    // Format: group.com.yourcompany.yourapp.widgets
    private static let appGroupIdentifier = "group.com.yourcompany.myapp.widgets"

    private static let streakDataKey = "widgetStreakData"

    /// Update widget with current streak data
    /// Call this from StreakDataProvider when streak data changes
    static func updateWidget(with streakData: StreakData) {
        guard AppConfiguration.enableWidgets else { return }

        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            debugPrint("WidgetHelper: Failed to access App Group: \(appGroupIdentifier)")
            return
        }

        // Convert to widget-compatible format
        let widgetData = WidgetStreakData(
            currentStreak: streakData.currentStreak,
            bestStreak: streakData.bestStreak,
            lastActivityDate: streakData.lastActivityDate,
            isAtRisk: streakData.isAtRisk
        )

        if let encoded = try? JSONEncoder().encode(widgetData) {
            sharedDefaults.set(encoded, forKey: streakDataKey)
            sharedDefaults.synchronize()
        }

        // Request widget timeline refresh
        WidgetCenter.shared.reloadTimelines(ofKind: "StreakWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "LockScreenStreakWidget")

        debugPrint("WidgetHelper: Updated widget with streak: \(streakData.currentStreak)")
    }

    /// Force refresh all widgets (call on app launch)
    static func refreshWidgets() {
        guard AppConfiguration.enableWidgets else { return }
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Widget Data Model (duplicated for main app target)

/// Streak data structure for widget display
/// This is duplicated from the widget extension to avoid cross-target dependencies
private struct WidgetStreakData: Codable {
    let currentStreak: Int
    let bestStreak: Int
    let lastActivityDate: Date?
    let isAtRisk: Bool
}
