# SwiftUI Indie Stack

*Do less. Ship more.*

A production-ready iOS app template with offline-first architecture. Battle-tested patterns extracted from a real production app.

> Koalas sleep 22 hours a day. They're not lazy — they're *efficient*. The best programmers think the same way. This template lets you ship in hours, not weeks.

---

## Features

- **Offline-First Architecture**: Works without Firebase - toggle backend features with a single flag
- **Authentication**: Apple Sign-In + Google Sign-In with Firebase Auth (optional)
- **Subscriptions**: RevenueCat integration with paywall support
- **Analytics**: Privacy-preserving analytics with TelemetryDeck
- **Streaks**: Backend-driven (Firebase) or local-only streak system
- **Library/CMS**: GitHub-based content system with markdown rendering
- **Widgets**: Home screen and lock screen widget templates
- **UI Theme**: Centralized color system with dark mode support

## Architecture Modes

The template supports two modes controlled by `AppConfiguration.useFirebase`:

### Local Mode (Default: `useFirebase = false`)
- **No Firebase required** - app works standalone
- Settings stored in UserDefaults
- Streaks tracked locally on device
- Device-based user ID for RevenueCat/TelemetryDeck
- Perfect for simple apps or rapid prototyping

### Cloud Mode (`useFirebase = true`)
- Full Firebase integration (Auth, Firestore, Crashlytics)
- Apple/Google Sign-In with anonymous user linking
- Settings sync across devices via Firestore
- Backend-driven streak calculation with reminders
- Requires Firebase project setup

## Project Structure

```
swiftui-indie-stack/
├── ios/                      # iOS app (Xcode project)
│   └── Sources/              # Main app target
│       ├── App/              # App entry point, configuration
│       ├── Auth/             # Authentication (conditional Firebase)
│       ├── User/             # Settings, Firestore manager
│       ├── Streak/           # Streak system (cloud or local)
│       ├── Paywall/          # RevenueCat integration
│       ├── Analytics/        # TelemetryDeck wrapper
│       ├── Library/          # GitHub-based CMS
│       ├── TabBar/           # Custom tab bar
│       ├── Onboarding/       # Onboarding flow
│       ├── UI/               # Theme, components, modifiers
│       └── Utilities/        # Logging, haptics
├── firebase-functions/       # Firebase backend (optional)
│   └── functions/            # Cloud Functions source
└── content/                  # CMS content (can be separate repo)
    ├── articles/             # Markdown articles
    └── index.json            # Content index
```

## Quick Start

### Option 1: Local Mode (No Firebase)

1. Clone the repository:
```bash
git clone https://github.com/cliffordh/swiftui-indie-stack.git
cd swiftui-indie-stack/ios
```

2. Open in Xcode and configure:
```swift
// AppConfiguration.swift
static let useFirebase = false        // Already set
static let useRevenueCat = true       // Set up RevenueCat
static let useTelemetryDeck = true    // Set up TelemetryDeck
```

3. Add your API keys:
```swift
static let revenueCatAPIKey = "appl_YOUR_KEY"
static let telemetryDeckAppID = "YOUR_APP_ID"
```

4. Build and run on simulator!

> **Running on device?** Update the bundle identifier first: Project → Target → Signing & Capabilities → change `com.example.myapp` to your own (e.g., `com.yourcompany.yourapp`). Simulator works without changes.

### Option 2: Cloud Mode (With Firebase)

1. Complete Local Mode setup above

2. Create Firebase project:
   - Go to [console.firebase.google.com](https://console.firebase.google.com)
   - Enable Authentication (Apple, Google providers)
   - Enable Firestore Database
   - Download `GoogleService-Info.plist`

3. Add Firebase to Xcode:
   - Add `GoogleService-Info.plist` to the project
   - Add Firebase SDK via SPM

4. Enable Firebase:
```swift
// AppConfiguration.swift
static let useFirebase = true
```

5. Deploy Firebase Functions:
```bash
cd firebase-functions/functions
npm install
firebase deploy
```

## Configuration

All app configuration is in `AppConfiguration.swift`:

```swift
enum AppConfiguration {
    // Feature toggles
    static let useFirebase = false       // Enable Firebase backend
    static let useRevenueCat = true      // Enable subscriptions
    static let useTelemetryDeck = true   // Enable analytics
    static let enableStreaks = true      // Enable streak feature
    static let enableLibrary = true      // Enable CMS feature

    // API Keys
    static let revenueCatAPIKey = "YOUR_KEY"
    static let telemetryDeckAppID = "YOUR_APP_ID"

    // URLs
    static let libraryIndexURL = "https://raw.githubusercontent.com/..."
    static let termsOfServiceURL = "https://..."
    static let privacyPolicyURL = "https://..."
}
```

## Modules

### Auth (`Sources/Auth/`)

**Local Mode**: Device-based identity for RevenueCat/TelemetryDeck. No sign-in UI.

**Cloud Mode**: Full Firebase Auth with Apple/Google Sign-In, anonymous auth, and credential linking.

```swift
// Check if sign-in is available
if AuthManager.shared.canSignIn {
    // Show sign-in UI
}

// Get user ID (works in both modes)
let userId = AuthManager.shared.userId
```

### Streak (`Sources/Streak/`)

**Local Mode**: Simple on-device streak tracking with UserDefaults.

**Cloud Mode**: Backend-driven streaks with Firebase Functions handling calculation, at-risk detection, and reminders.

```swift
// Record activity (works in both modes)
if AppConfiguration.useFirebase {
    FirestoreManager.shared.logActivity(type: "lesson_completed")
} else {
    StreakDataProvider.shared.recordLocalActivity()
}

// Display streak
StreakBadgeView()  // Shows current streak with animation
```

### Paywall (`Sources/Paywall/`)

RevenueCat integration for subscriptions. Works identically in both modes.

```swift
// Show paywall
PaywallManager.shared.triggerPaywall()

// Check subscription
let isSubscribed = await PaywallManager.shared.checkSubscriptionStatus()
```

### Library (`Sources/Library/`)

GitHub-based CMS for documentation. Independent of Firebase.

```swift
// Content is fetched from your GitHub repo
// Edit AppConfiguration.libraryIndexURL to point to your content
```

### Settings (`Sources/User/SettingsViewModel.swift`)

Offline-first settings with optional cloud sync.

**Local Mode**: All settings stored in UserDefaults via @AppStorage.

**Cloud Mode**: Settings sync to Firestore when changed.

```swift
// Settings always work locally
SettingsViewModel.shared.appearance = .dark

// If Firebase enabled, changes sync automatically
```

## Firebase Functions

The `firebase-functions/` directory contains the backend for cloud mode:

- `createUserRecord` - Creates user document on signup
- `updateStreak` - Calculates streak when activity logged
- `checkStreaksAtRisk` - Daily check (6 PM) for at-risk streaks
- `resetBrokenStreaks` - Daily reset (midnight) of broken streaks

Deploy with:
```bash
cd firebase-functions/functions
npm install
npm run deploy
```

## Dependencies

| Package | Version | Purpose | Required |
|---------|---------|---------|----------|
| RevenueCat | ~> 5.31 | Subscriptions | Optional |
| TelemetryDeck | ~> 2.9 | Analytics | Optional |
| Firebase | ~> 11.8 | Auth, Firestore | Optional |
| GoogleSignIn | ~> 8.0 | Google auth | Optional |
| swift-markdown-ui | ~> 2.4 | Markdown rendering | Yes |
| ConfettiSwiftUI | ~> 1.1 | Celebration effects | Yes |
| SwiftUI-Shimmer | ~> 1.5 | Loading effects | Yes |
| NetworkImage | ~> 6.0 | Async image loading | Yes |

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Customization

See [CUSTOMIZATION.md](./CUSTOMIZATION.md) for detailed guides on:
- Branding and colors
- Adding/removing tabs
- Customizing streaks
- Setting up the CMS
- Paywall configuration

## License

MIT License - see LICENSE file

---

## Acknowledgments

Patterns extracted from [MyBodyWatch](https://mybodywatch.app), a production iOS app.

**Extraction assistance** by [Claude](https://claude.ai) (Anthropic) with human-guided oversight by [@cliffordh](https://github.com/cliffordh).
