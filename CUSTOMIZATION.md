# Customization Guide

This guide explains how to customize SwiftUI Indie Stack for your app.

## Table of Contents

1. [Branding & Colors](#branding--colors)
2. [App Configuration](#app-configuration)
3. [Streak System](#streak-system)
4. [GitHub CMS](#github-cms)
5. [Paywall](#paywall)

---

## Branding & Colors

### Option 1: Use Color Assets (Recommended)

1. Open `ios/Sources/UI/Assets.xcassets`
2. Add or modify the following color sets:
   - `PrimaryGreen` - Main action color
   - `PrimaryBlue` - Secondary color
   - `AccentOrange` - Accent/highlight color
   - `TabHome`, `TabLibrary`, `TabSettings` - Tab bar colors

3. Each color set should have both light and dark mode variants

### Option 2: Use Hex Colors

Edit `ios/Sources/UI/Theme/AppColors.swift`:

```swift
struct AppColors {
    // Change these hex values
    static let primary = Color(hex: "#58CC02")      // Your primary color
    static let secondary = Color(hex: "#1CB0F6")   // Your secondary color
    static let accent = Color(hex: "#FF9600")       // Your accent color

    // ... other colors
}
```

### Fonts

Edit `ios/Sources/UI/Theme/AppFonts.swift` to use custom fonts:

```swift
struct AppFonts {
    static let title = Font.custom("YourFont-Bold", size: 28)
    static let body = Font.custom("YourFont-Regular", size: 17)
    // ...
}
```

---

## App Configuration

### 1. Bundle Identifier

The template uses `com.example.myapp` as a placeholder. **Simulator builds work without changes**, but you must update the bundle identifier before running on a physical device.

1. Open the Xcode project
2. Select the project in the navigator
3. Select the main app target → Signing & Capabilities
4. Change "Bundle Identifier" to your own (e.g., `com.yourcompany.yourapp`)
5. Repeat for the widget extension target (`com.yourcompany.yourapp.widget`)
6. Select your development team

### 2. App Name

1. Update `CFBundleDisplayName` in `Info.plist`
2. Update app name references in:
   - `LoginView.swift`
   - `OnboardingView.swift`

### 3. URLs and Links

Search for and replace these placeholders:

```
YOUR_BUNDLE_ID           → com.yourcompany.yourapp
YOUR_REVENUECAT_API_KEY  → appl_xxxxxxxxxxxxx
YOUR_TELEMETRYDECK_APP_ID → XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
https://yourapp.com      → Your actual website
support@yourapp.com      → Your support email
```

### 4. Firebase Configuration

1. Replace `GoogleService-Info.plist` with your Firebase project's config file
2. Update `ios/Firebase/functions/.firebaserc` with your project ID

---

## Streak System

### Understanding the Architecture

The streak system is **backend-driven**:
- **Frontend** (iOS): Displays streak data from Firestore
- **Backend** (Firebase Functions): Calculates streaks, sends reminders

### Customizing Streak Behavior

Edit `ios/Firebase/functions/index.ts`:

#### Change reminder time
```typescript
// Default: 6 PM
export const checkStreaksAtRisk = functions.pubsub
    .schedule("0 18 * * *")  // Change this cron expression
    .timeZone("America/New_York")  // Change timezone
```

#### Change streak reset time
```typescript
// Default: Midnight
export const resetBrokenStreaks = functions.pubsub
    .schedule("0 0 * * *")  // Change this cron expression
```

### Logging Activity

To count something toward the streak, log activity from your app:

```swift
// In your view or view model
FirestoreManager.shared.logActivity(type: "lesson_completed")
```

The `type` parameter is flexible - use any string that describes the activity.

### Customizing Streak UI

#### Badge Colors

Edit `ios/Sources/Streak/StreakBadgeView.swift`:

```swift
private var flameColor: Color {
    let streak = streakProvider.streakData.currentStreak

    if streak >= 365 { return .purple }   // Legendary
    if streak >= 100 { return .blue }     // Epic
    if streak >= 30 { return .orange }    // Hot
    // Add more tiers...
}
```

#### Milestone Confetti

```swift
var isMilestone: Bool {
    let milestones = [7, 30, 50, 100, 200, 365]  // Customize milestones
    return milestones.contains(streakData.currentStreak)
}
```

---

## GitHub CMS

### Setting Up Your Content Repository

1. Create a new GitHub repository (can be public or private)
2. Add `index.json` at the root
3. Add markdown files in `articles/` directory
4. Add images in `images/` directory

### Update the Content URL

Edit `ios/Sources/Library/ViewModels/LibraryViewModel.swift`:

```swift
private let indexURL = "https://raw.githubusercontent.com/YOUR_ORG/YOUR_REPO/main/index.json"
```

### Content Structure

Your `index.json` should follow this structure:

```json
{
  "version": "1.0",
  "lastUpdated": "2025-01-01T00:00:00Z",
  "articles": [
    {
      "id": "unique-article-id",
      "title": "Article Title",
      "summary": "Brief description shown in list",
      "category": "category_slug",
      "publishDate": "2025-01-01T00:00:00Z",
      "expiryDate": null,
      "contentURL": "https://raw.githubusercontent.com/.../article.md",
      "imageURL": "https://raw.githubusercontent.com/.../image.jpg",
      "featured": false,
      "version": "1.0"
    }
  ]
}
```

### Adding Categories

Categories are auto-generated from article `category` fields. To customize colors:

Edit `ios/Sources/Library/Models/LibraryModel.swift`:

```swift
extension String {
    var categoryColor: Color {
        switch self.lowercased() {
        case "tutorials": return .blue
        case "tips": return .green
        case "news": return .orange
        // Add your categories...
        default: return .gray
        }
    }
}
```

---

## Paywall

### Using RevenueCat's Built-in Paywall

The template uses RevenueCatUI for paywall display. Configure your paywall in the RevenueCat dashboard:

1. Go to RevenueCat Dashboard → Your App → Paywalls
2. Design your paywall using the visual editor
3. The app will automatically use your configured paywall

### Triggering the Paywall

```swift
// Show paywall manually
PaywallManager.shared.triggerPaywall()

// Show paywall if not subscribed
PaywallManager.shared.showPaywallIfNeeded()

// Check subscription status
let isSubscribed = await PaywallManager.shared.checkSubscriptionStatus()

// Check specific entitlement
let hasPremium = await PaywallManager.shared.hasEntitlement("premium")
```

### Paywall Timing

The default shows paywall when `showPaywallIfNeeded()` is called (on app launch). Customize the logic in `PaywallManager.swift`.

---

## Tab Bar

### Adding/Removing Tabs

Edit `ios/Sources/TabBar/MainTabView.swift`:

```swift
HStack {
    TabBarIcon(selectedTab: $selectedTab, assignedTab: 0,
               systemIconName: "house.fill", tabName: "Home",
               color: AppColors.tabHome)

    // Add or remove tabs here

    TabBarIcon(selectedTab: $selectedTab, assignedTab: 1,
               systemIconName: "book.fill", tabName: "Library",
               color: AppColors.tabLibrary)
}
```

Update the switch statement in the body to handle new tabs:

```swift
switch selectedTab {
case 0: HomeView()
case 1: LibraryView()
case 2: YourNewView()  // Add new view
case 3: SettingsView()
default: HomeView()
}
```

---

## Onboarding

Edit `ios/Sources/Onboarding/OnboardingView.swift`:

```swift
private let pages: [OnboardingPage] = [
    OnboardingPage(
        title: "Welcome",
        description: "Your custom welcome message",
        imageName: "hand.wave.fill",
        imageColor: .orange
    ),
    // Add more pages...
]
```

---

## Need Help?

### Community Support
- Open an issue on [GitHub](https://github.com/cliffordh/swiftui-indie-stack/issues)
- Check existing issues for common questions

### Professional Services

Need help customizing this template for your app? Professional assistance is available:

- **Website:** [pagescholar.com](https://www.pagescholar.com)
- **GitHub:** [@cliffordh](https://github.com/cliffordh)

Services include:
- Custom feature development
- Firebase backend setup and configuration
- App Store submission assistance
- Code review and architecture consulting
