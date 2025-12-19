//
//  StreakBadgeView.swift
//  MyApp
//
//  Displays the current streak with flame animation.
//

import SwiftUI
import ConfettiSwiftUI

struct StreakBadgeView: View {
    @ObservedObject var streakProvider = StreakDataProvider.shared

    @State private var confettiTrigger = 0
    @State private var isAnimating = false

    var size: CGFloat = 60

    var body: some View {
        ZStack {
            // Flame icon
            Image(systemName: streakProvider.hasStreak ? "flame.fill" : "flame")
                .font(.system(size: size * 0.6))
                .foregroundColor(flameColor)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    streakProvider.hasStreak ?
                        Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) :
                        .default,
                    value: isAnimating
                )

            // Streak count
            if streakProvider.hasStreak {
                Text("\(streakProvider.streakData.currentStreak)")
                    .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .offset(y: size * 0.15)
            }

            // Confetti for milestones
            ConfettiCannon(
                trigger: $confettiTrigger,
                num: 50,
                colors: [.orange, .red, .yellow],
                rainHeight: 400,
                radius: 300
            )
        }
        .frame(width: size, height: size)
        .onAppear {
            isAnimating = streakProvider.hasStreak
        }
        .onChange(of: streakProvider.streakData.currentStreak) { oldValue, newValue in
            // Trigger confetti on milestone achievements
            if streakProvider.isMilestone && newValue > oldValue {
                confettiTrigger += 1
            }
        }
    }

    private var flameColor: Color {
        if !streakProvider.hasStreak {
            return .gray
        }

        let streak = streakProvider.streakData.currentStreak

        if streak >= 365 {
            return .purple  // Legendary
        } else if streak >= 100 {
            return .blue    // Epic
        } else if streak >= 30 {
            return Color.orange  // Hot
        } else if streak >= 7 {
            return .orange  // Warm
        } else {
            return .red     // Starting
        }
    }
}

// MARK: - Compact Streak Badge

struct CompactStreakBadge: View {
    @ObservedObject var streakProvider = StreakDataProvider.shared

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: streakProvider.hasStreak ? "flame.fill" : "flame")
                .foregroundColor(streakProvider.hasStreak ? .orange : .gray)

            Text("\(streakProvider.streakData.currentStreak)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(streakProvider.hasStreak ? .primary : .secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(streakProvider.hasStreak ?
                      Color.orange.opacity(0.15) :
                      Color.secondary.opacity(0.1))
        )
    }
}

// MARK: - Streak At Risk Banner

struct StreakAtRiskBanner: View {
    @ObservedObject var streakProvider = StreakDataProvider.shared

    var body: some View {
        if streakProvider.streakData.isAtRisk && streakProvider.hasStreak {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)

                Text("Complete an activity today to keep your \(streakProvider.streakData.currentStreak)-day streak!")
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .background(Color.yellow.opacity(0.15))
            .cornerRadius(12)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        StreakBadgeView()
        CompactStreakBadge()
        StreakAtRiskBanner()
    }
    .padding()
}
