//
//  LockScreenStreakWidget.swift
//  MyAppWidget
//
//  Lock screen widgets for iOS 16+.
//  Supports circular, inline, and rectangular accessory widgets.
//

import WidgetKit
import SwiftUI

// MARK: - Lock Screen Timeline Provider

struct LockScreenTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streakData: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        let streakData = WidgetDataManager.getStreakDataOrPlaceholder()
        completion(StreakEntry(date: Date(), streakData: streakData))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let streakData = WidgetDataManager.getStreakDataOrPlaceholder()
        let currentDate = Date()

        let entry = StreakEntry(date: currentDate, streakData: streakData)

        // Refresh at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)

        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}

// MARK: - Lock Screen Widget Configuration

struct LockScreenStreakWidget: Widget {
    let kind: String = "LockScreenStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LockScreenTimelineProvider()) { entry in
            LockScreenStreakWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Streak")
        .description("Quick glance at your streak.")
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}

// MARK: - Lock Screen Widget View

struct LockScreenStreakWidgetEntryView: View {
    var entry: StreakEntry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            CircularStreakView(streakData: entry.streakData)
        case .accessoryInline:
            InlineStreakView(streakData: entry.streakData)
        case .accessoryRectangular:
            RectangularStreakView(streakData: entry.streakData)
        default:
            CircularStreakView(streakData: entry.streakData)
        }
    }
}

// MARK: - Circular Widget (Lock Screen)

struct CircularStreakView: View {
    let streakData: WidgetStreakData

    var body: some View {
        ZStack {
            // Progress ring (visual indicator based on streak milestone progress)
            AccessoryWidgetBackground()

            // Gauge showing progress to next milestone
            Gauge(value: progressToNextMilestone, in: 0...1) {
                // Label (not shown in circular)
            } currentValueLabel: {
                VStack(spacing: 0) {
                    Image(systemName: streakData.currentStreak > 0 ? "flame.fill" : "flame")
                        .font(.system(size: 12))
                    Text("\(streakData.currentStreak)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
            .gaugeStyle(.accessoryCircular)
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    /// Progress toward next streak milestone (7, 30, 100, 365)
    private var progressToNextMilestone: Double {
        let streak = streakData.currentStreak
        let milestones = [7, 30, 100, 365]

        // Find next milestone
        for (index, milestone) in milestones.enumerated() {
            if streak < milestone {
                let previousMilestone = index > 0 ? milestones[index - 1] : 0
                let progress = Double(streak - previousMilestone) / Double(milestone - previousMilestone)
                return progress
            }
        }

        // Beyond all milestones
        return 1.0
    }
}

// MARK: - Inline Widget (Lock Screen - Text only)

struct InlineStreakView: View {
    let streakData: WidgetStreakData

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
            Text("\(streakData.currentStreak) day streak")
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

// MARK: - Rectangular Widget (Lock Screen)

struct RectangularStreakView: View {
    let streakData: WidgetStreakData

    var body: some View {
        HStack(spacing: 8) {
            // Flame icon
            Image(systemName: streakData.currentStreak > 0 ? "flame.fill" : "flame")
                .font(.system(size: 28))
                .frame(width: 32)

            // Streak info
            VStack(alignment: .leading, spacing: 2) {
                Text("\(streakData.currentStreak) day streak")
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)

                HStack(spacing: 4) {
                    if streakData.isAtRisk {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                        Text("Complete today!")
                            .font(.system(size: 11))
                    } else {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 10))
                        Text("Best: \(streakData.bestStreak)")
                            .font(.system(size: 11))
                    }
                }
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

// MARK: - Previews

#Preview("Circular", as: .accessoryCircular) {
    LockScreenStreakWidget()
} timeline: {
    StreakEntry(date: Date(), streakData: WidgetStreakData(currentStreak: 14, bestStreak: 30, lastActivityDate: Date(), isAtRisk: false))
    StreakEntry(date: Date(), streakData: WidgetStreakData(currentStreak: 0, bestStreak: 7, lastActivityDate: nil, isAtRisk: false))
}

#Preview("Inline", as: .accessoryInline) {
    LockScreenStreakWidget()
} timeline: {
    StreakEntry(date: Date(), streakData: WidgetStreakData(currentStreak: 7, bestStreak: 14, lastActivityDate: Date(), isAtRisk: false))
}

#Preview("Rectangular", as: .accessoryRectangular) {
    LockScreenStreakWidget()
} timeline: {
    StreakEntry(date: Date(), streakData: WidgetStreakData(currentStreak: 42, bestStreak: 100, lastActivityDate: Date(), isAtRisk: false))
    StreakEntry(date: Date(), streakData: WidgetStreakData(currentStreak: 7, bestStreak: 14, lastActivityDate: Date().addingTimeInterval(-86400), isAtRisk: true))
}
