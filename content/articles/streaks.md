# Streak System

Engage your users with the built-in streak tracking system. Streaks encourage daily app usage through gamification.

## How It Works

Users maintain a streak by using the app daily. The streak count increments each consecutive day and resets if a day is missed.

### Streak Milestones
- 7 days: Warm streak
- 30 days: Hot streak
- 100 days: Epic streak
- 365 days: Legendary streak

Each milestone triggers a confetti celebration!

## Components

### StreakBadgeView
The main streak display with animated flame:

```swift
// Standard size
StreakBadgeView()

// Custom size
StreakBadgeView(size: 80)
```

### CompactStreakBadge
Smaller badge for navigation bars or lists:

```swift
CompactStreakBadge()
```

### StreakAtRiskBanner
Warns users when they haven't used the app today:

```swift
StreakAtRiskBanner()
```

## Recording Activity

Mark app usage to maintain streaks:

```swift
SettingsViewModel.shared.markAppUsage()
```

This is called automatically in `MainTabView`, but you can call it after specific actions:

```swift
// After completing a lesson, workout, etc.
func completeActivity() {
    // Your activity code
    SettingsViewModel.shared.markAppUsage()
}
```

## Local vs Cloud Streaks

### Local Mode
Streaks are calculated on-device using UserDefaults:
- Streak data stored locally
- Calculated based on `lastActivityDate`
- Simpler but device-specific

### Cloud Mode
Streaks are calculated server-side:
- Cloud Function runs on activity
- More reliable across devices
- Prevents tampering

## Widgets

The streak system includes home screen and lock screen widgets:

### Home Screen Widgets
- **Small**: Flame icon with streak count
- **Medium**: Adds motivational message

### Lock Screen Widgets
- **Circular**: Compact flame with count
- **Inline**: Text-based for complications
- **Rectangular**: Larger display

See the **Home Screen Widgets** article for setup details.

## Customization

### Changing Colors
Edit `StreakBadgeView.swift` to modify the `flameColor` computed property:

```swift
private var flameColor: Color {
    let streak = streakProvider.streakData.currentStreak
    if streak >= 365 { return .purple }  // Change these
    else if streak >= 100 { return .blue }
    // ...
}
```

### Changing Milestones
Edit `StreakDataProvider.swift`:

```swift
var isMilestone: Bool {
    [7, 30, 100, 365].contains(streakData.currentStreak)
}
```

## Disabling Streaks

```swift
static let enableStreaks = false
```

Hide streak UI elements when disabled:

```swift
if AppConfiguration.enableStreaks {
    StreakBadgeView()
}
```
