# Customization Tips

Best practices for making SwiftUI Indie Stack your own.

## Branding Checklist

### 1. App Name and Icons
- [ ] Update display name in Xcode
- [ ] Replace app icon in Assets.xcassets
- [ ] Update `AppConfiguration.appName`

### 2. Colors
- [ ] Update colors in Assets.xcassets
- [ ] Modify `AppColors.swift` if needed
- [ ] Change accent color

### 3. Fonts (Optional)
- [ ] Add custom fonts to project
- [ ] Update `AppFonts.swift`

### 4. URLs and Contact
- [ ] Update Terms of Service URL
- [ ] Update Privacy Policy URL
- [ ] Update support email

## Color System

Colors are defined in two places:

### Asset Catalog
`Sources/Assets.xcassets/` contains color sets:
- PrimaryGreen, PrimaryBlue, AccentOrange
- TabHome, TabLibrary, TabSettings
- BackgroundPrimary, BackgroundSecondary

### AppColors.swift
References the asset catalog with fallbacks:

```swift
static let primary = Color("PrimaryGreen")
static let accent = Color("AccentOrange")
```

## Updating Colors

### Method 1: Asset Catalog (Recommended)
1. Open Assets.xcassets in Xcode
2. Select color set
3. Update color values
4. Supports dark mode variants

### Method 2: Code
Edit `AppColors.swift` for code-based colors:

```swift
static let primary = Color(hex: "FF9500")
```

## Adding Features

### New Tab
1. Add view in `Sources/` folder
2. Update `MainTabView.swift`:

```swift
case 3:
    YourNewView()

// Add tab icon
TabBarIcon(
    selectedTab: $selectedTab,
    assignedTab: 3,
    systemIconName: "star.fill",
    tabName: "New Tab",
    color: AppColors.accent
)
```

### New Screen
1. Create SwiftUI view file
2. Add navigation from existing screens
3. Track screen view:

```swift
.task {
    Analytics.trackScreenView("YourNewScreen")
}
```

## Removing Features

### Remove Library
```swift
static let enableLibrary = false
```
Then remove Library tab from MainTabView.

### Remove Streaks
```swift
static let enableStreaks = false
```
Remove StreakBadgeView and related UI.

### Remove Subscriptions
```swift
static let useRevenueCat = false
```
Remove subscription-related UI in Settings.

## Code Patterns

### Adding Analytics
```swift
Analytics.track(event: "button_tapped", parameters: [
    "button_name": "signup",
    "screen": "onboarding"
])
```

### Checking Feature Flags
```swift
if AppConfiguration.enableStreaks {
    // Show streak UI
}
```

### Conditional Firebase Code
```swift
#if canImport(Firebase)
if AppConfiguration.useFirebase {
    // Firebase-specific code
}
#endif
```

## Testing Checklist

Before release:
- [ ] Test in Local Mode
- [ ] Test in Cloud Mode (if using Firebase)
- [ ] Test subscription flow with Sandbox
- [ ] Test widgets on device
- [ ] Test offline behavior
- [ ] Test on multiple device sizes

## Common Customizations

### Change Onboarding
Edit `OnboardingView.swift` to customize:
- Number of pages
- Content and images
- Skip/continue behavior

### Modify Home Screen
Edit `HomeView` in `MainTabView.swift`:
- Replace placeholder content
- Add your main app functionality

### Custom Paywall
While RevenueCat's native paywall is recommended, you can create custom UI:
1. Create custom view
2. Call RevenueCat purchase APIs directly
3. Replace `PaywallPresenter` modifier
