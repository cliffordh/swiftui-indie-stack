//
//  StreakModel.swift
//  MyApp
//
//  Data structures for the streak system.
//

import Foundation

/// Streak data model
struct StreakData: Codable {
    let currentStreak: Int
    let bestStreak: Int
    let lastActivityDate: Date?
    let streakStartDate: Date?
    let isAtRisk: Bool
    let freezesAvailable: Int
    let freezeActive: Bool
    let activeDays: [Date]  // Days with activity in current month (for calendar)

    static var empty: StreakData {
        StreakData(
            currentStreak: 0,
            bestStreak: 0,
            lastActivityDate: nil,
            streakStartDate: nil,
            isAtRisk: false,
            freezesAvailable: 0,
            freezeActive: false,
            activeDays: []
        )
    }
}

// MARK: - Streak Milestones

extension StreakData {
    /// Standard milestone values
    static let milestones = [7, 30, 50, 100, 200, 365, 500, 1000]

    /// Whether current streak is a milestone
    var isMilestone: Bool {
        Self.milestones.contains(currentStreak)
    }

    /// Next milestone to achieve
    var nextMilestone: Int? {
        Self.milestones.first { $0 > currentStreak }
    }

    /// Progress toward next milestone (0.0 to 1.0)
    var progressToNextMilestone: Double {
        guard let next = nextMilestone else { return 1.0 }
        let previous = Self.milestones.last { $0 < currentStreak } ?? 0
        let range = next - previous
        let progress = currentStreak - previous
        return Double(progress) / Double(range)
    }
}
