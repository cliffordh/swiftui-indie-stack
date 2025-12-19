//
//  WidgetDataModels.swift
//  MyAppWidget
//
//  Shared data models for widget data handling.
//  Uses App Groups to share data between main app and widget extension.
//

import Foundation
import WidgetKit

// MARK: - Widget Data Model

/// Streak data structure for widget display
struct WidgetStreakData: Codable {
    let currentStreak: Int
    let bestStreak: Int
    let lastActivityDate: Date?
    let isAtRisk: Bool

    /// Check if streak is active (activity within last 2 days)
    var isActive: Bool {
        guard let lastActivity = lastActivityDate else { return false }
        let daysSinceActivity = Calendar.current.dateComponents([.day], from: lastActivity, to: Date()).day ?? 0
        return daysSinceActivity < 2
    }

    /// User-friendly streak text
    var streakText: String {
        if currentStreak == 1 {
            return "1 day"
        } else {
            return "\(currentStreak) days"
        }
    }

    /// Short streak text for lock screen
    var shortText: String {
        "\(currentStreak)d"
    }

    static var placeholder: WidgetStreakData {
        WidgetStreakData(
            currentStreak: 7,
            bestStreak: 14,
            lastActivityDate: Date(),
            isAtRisk: false
        )
    }

    static var empty: WidgetStreakData {
        WidgetStreakData(
            currentStreak: 0,
            bestStreak: 0,
            lastActivityDate: nil,
            isAtRisk: false
        )
    }
}

// MARK: - Timeline Entry

struct StreakEntry: TimelineEntry {
    let date: Date
    let streakData: WidgetStreakData
}

// MARK: - Widget Data Manager

/// Manages shared data between main app and widget extension via App Groups
struct WidgetDataManager {

    // IMPORTANT: Replace with your actual App Group identifier
    // Format: group.com.yourcompany.yourapp.widgets
    private static let appGroupIdentifier = "group.com.yourcompany.myapp.widgets"

    private static let streakDataKey = "widgetStreakData"

    /// Store streak data from main app (call this when streak updates)
    static func storeStreakData(_ data: WidgetStreakData) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            debugPrint("Failed to access App Group: \(appGroupIdentifier)")
            return
        }

        if let encoded = try? JSONEncoder().encode(data) {
            sharedDefaults.set(encoded, forKey: streakDataKey)
            sharedDefaults.synchronize()
        }

        // Request widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: "StreakWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "LockScreenStreakWidget")
    }

    /// Retrieve streak data in widget extension
    static func getStreakData() -> WidgetStreakData? {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = sharedDefaults.data(forKey: streakDataKey),
              let streakData = try? JSONDecoder().decode(WidgetStreakData.self, from: data) else {
            return nil
        }
        return streakData
    }

    /// Get streak data or placeholder for widget display
    static func getStreakDataOrPlaceholder() -> WidgetStreakData {
        getStreakData() ?? .empty
    }
}
