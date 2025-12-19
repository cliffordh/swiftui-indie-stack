//
//  StreakWidget.swift
//  MyAppWidget
//
//  Home screen widget showing current streak.
//  Supports small and medium widget sizes.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct StreakTimelineProvider: TimelineProvider {

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

        // Create entry for now
        let entry = StreakEntry(date: currentDate, streakData: streakData)

        // Refresh at midnight (when streak might change)
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)

        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}

// MARK: - Widget Configuration

struct StreakWidget: Widget {
    let kind: String = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakTimelineProvider()) { entry in
            StreakWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Streak")
        .description("Track your current streak.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget View

struct StreakWidgetEntryView: View {
    var entry: StreakEntry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallStreakView(streakData: entry.streakData)
        case .systemMedium:
            MediumStreakView(streakData: entry.streakData)
        default:
            SmallStreakView(streakData: entry.streakData)
        }
    }
}

// MARK: - Small Widget View

struct SmallStreakView: View {
    let streakData: WidgetStreakData

    var body: some View {
        ZStack {
            // Background gradient
            ContainerRelativeShape()
                .fill(
                    LinearGradient(
                        colors: [flameColor.opacity(0.8), flameColor.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 8) {
                // Flame icon
                Image(systemName: streakData.currentStreak > 0 ? "flame.fill" : "flame")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)

                // Streak count
                Text("\(streakData.currentStreak)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Label
                Text(streakData.currentStreak == 1 ? "day" : "days")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    private var flameColor: Color {
        let streak = streakData.currentStreak
        if streak == 0 { return .gray }
        if streak >= 365 { return .purple }
        if streak >= 100 { return .blue }
        if streak >= 30 { return .orange }
        if streak >= 7 { return .orange }
        return .orange
    }
}

// MARK: - Medium Widget View

struct MediumStreakView: View {
    let streakData: WidgetStreakData

    var body: some View {
        ZStack {
            // Background
            ContainerRelativeShape()
                .fill(
                    LinearGradient(
                        colors: [flameColor.opacity(0.7), flameColor.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            HStack(spacing: 20) {
                // Left side - Flame and count
                VStack(spacing: 4) {
                    Image(systemName: streakData.currentStreak > 0 ? "flame.fill" : "flame")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)

                    Text("\(streakData.currentStreak)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(streakData.currentStreak == 1 ? "day streak" : "day streak")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)

                // Divider
                Rectangle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 1)
                    .padding(.vertical, 16)

                // Right side - Stats
                VStack(alignment: .leading, spacing: 12) {
                    StatRow(icon: "trophy.fill", label: "Best", value: "\(streakData.bestStreak)")

                    if streakData.isAtRisk {
                        StatRow(icon: "exclamationmark.triangle.fill", label: "At Risk", value: "Today!")
                    } else if streakData.currentStreak > 0 {
                        StatRow(icon: "checkmark.circle.fill", label: "Status", value: "Active")
                    } else {
                        StatRow(icon: "arrow.counterclockwise", label: "Status", value: "Start today")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    private var flameColor: Color {
        let streak = streakData.currentStreak
        if streak == 0 { return .gray }
        if streak >= 365 { return .purple }
        if streak >= 100 { return .blue }
        if streak >= 30 { return .orange }
        return .orange
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    StreakWidget()
} timeline: {
    StreakEntry(date: Date(), streakData: WidgetStreakData(currentStreak: 14, bestStreak: 30, lastActivityDate: Date(), isAtRisk: false))
    StreakEntry(date: Date(), streakData: WidgetStreakData(currentStreak: 0, bestStreak: 7, lastActivityDate: nil, isAtRisk: false))
}

#Preview("Medium", as: .systemMedium) {
    StreakWidget()
} timeline: {
    StreakEntry(date: Date(), streakData: WidgetStreakData(currentStreak: 42, bestStreak: 100, lastActivityDate: Date(), isAtRisk: false))
    StreakEntry(date: Date(), streakData: WidgetStreakData(currentStreak: 7, bestStreak: 14, lastActivityDate: Date().addingTimeInterval(-86400), isAtRisk: true))
}
