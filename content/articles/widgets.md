# Home Screen Widgets

SwiftUI Indie Stack includes ready-to-use widgets for the home screen and lock screen.

## Included Widgets

### Home Screen Widgets

**StreakWidget (Small)**
- Displays flame icon and streak count
- Shows "No streak" when inactive
- Color changes based on streak milestone

**StreakWidget (Medium)**
- Same as small plus motivational message
- Shows "Start your streak today!" for new users
- Dynamic messages based on streak length

### Lock Screen Widgets

**Circular**
- Compact flame with streak count
- Perfect for watch complications style

**Inline**
- Text-only: "7 day streak" format
- For status bar or small spaces

**Rectangular**
- Larger display with more detail
- Shows streak status message

## Setup in Xcode

The widget extension is in the `Widget/` folder. To add it to your project:

1. In Xcode, go to **File > Add Target**
2. Select **Widget Extension**
3. Name it (e.g., "YourAppWidget")
4. Copy code from `Widget/` folder
5. Set up App Group (see below)

## App Groups

Widgets need App Groups to share data with the main app.

### 1. Create App Group
1. Go to Apple Developer Portal
2. Create identifier: `group.com.yourcompany.yourapp`

### 2. Enable in Main App
1. Select app target > Signing & Capabilities
2. Add **App Groups** capability
3. Select your group

### 3. Enable in Widget
1. Select widget target > Signing & Capabilities
2. Add **App Groups** capability
3. Select the same group

### 4. Update Code
In `WidgetDataModels.swift`, update the group identifier:

```swift
static let suiteName = "group.com.yourcompany.yourapp"
```

## How Data Flows

```
Main App                     Widget
    │                           │
    ├─── markAppUsage() ────────┤
    │                           │
    ▼                           │
UserDefaults (App Group) ◄──────┘
    │                           │
    ├─── WidgetHelper.sync() ───┤
    │                           │
    ▼                           ▼
Widget Data Store         Widget reads
    │                     and displays
    └─── WidgetCenter.reloadAllTimelines()
```

## Updating Widget Content

The main app automatically updates widgets when streaks change:

```swift
// In StreakDataProvider
WidgetHelper.syncStreakToWidget(streak: currentStreak)
```

To manually refresh:

```swift
import WidgetKit
WidgetCenter.shared.reloadAllTimelines()
```

## Customizing Widgets

### Change Widget Appearance
Edit the widget view files in `Widget/`:
- `StreakWidget.swift` - Home screen widgets
- `LockScreenStreakWidget.swift` - Lock screen widgets

### Add New Widgets
1. Create new widget view
2. Add to `MyAppWidgetBundle.swift`
3. Define supported sizes

### Change Refresh Timeline

```swift
func getTimeline(in context: Context,
                 completion: @escaping (Timeline<Entry>) -> Void) {
    // Current approach: refresh at midnight
    let midnight = Calendar.current.startOfDay(for: Date())
    let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!

    // Change to refresh more/less frequently
}
```

## Disabling Widgets

```swift
static let enableWidgets = false
```

You can also simply not include the widget target when archiving for App Store.
