# Architecture Overview

SwiftUI Indie Stack uses an **offline-first architecture** that works without any backend, but scales to full cloud sync when needed.

## The Two Modes

### Local Mode (`useFirebase = false`)

```
┌─────────────────────────────────────┐
│           SwiftUI Views             │
├─────────────────────────────────────┤
│           ViewModels                │
├─────────────────────────────────────┤
│         UserDefaults                │
└─────────────────────────────────────┘
```

- All data stored in UserDefaults
- Device-based anonymous identity
- Streaks tracked locally
- No network required

### Cloud Mode (`useFirebase = true`)

```
┌─────────────────────────────────────┐
│           SwiftUI Views             │
├─────────────────────────────────────┤
│           ViewModels                │
├─────────────────────────────────────┤
│       FirestoreManager              │
├─────────────────────────────────────┤
│    Firebase Auth + Firestore        │
├─────────────────────────────────────┤
│       Cloud Functions               │
└─────────────────────────────────────┘
```

- Firebase Auth for user identity
- Firestore for data persistence
- Real-time sync across devices
- Server-side streak calculation

## Conditional Compilation

All Firebase code uses guards:

```swift
#if canImport(Firebase)
if AppConfiguration.useFirebase {
    // Firebase-specific code
}
#endif
```

This means the app compiles and runs even without Firebase SDK.

## Key Managers

### AuthManager
Handles authentication in both modes:
- **Local**: Generates device-based UUID
- **Cloud**: Firebase Auth with Apple/Google sign-in

### SettingsViewModel
User preferences and settings:
- **Local**: UserDefaults storage
- **Cloud**: Firestore sync

### StreakDataProvider
Streak display and tracking:
- **Local**: UserDefaults-based calculation
- **Cloud**: Listens to Firestore for server-calculated streaks

### PaywallManager
RevenueCat integration:
- Same behavior in both modes
- Manages subscription state
- Presents paywall UI

## Data Flow

### Reading Data
```
View -> @ObservedObject ViewModel -> Data Source
```

### Writing Data (Local Mode)
```
View Action -> ViewModel -> UserDefaults -> @Published update
```

### Writing Data (Cloud Mode)
```
View Action -> ViewModel -> FirestoreManager -> Firestore
                                    ↓
              @Published update <- Firestore Listener
```

## When to Use Each Mode

### Use Local Mode When:
- Building an MVP or prototype
- App doesn't need cloud features
- Privacy-focused apps
- Offline-only apps

### Use Cloud Mode When:
- Need user accounts
- Multi-device sync required
- Server-side logic needed
- Social features planned
