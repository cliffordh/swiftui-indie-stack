# Quick Start Guide

Get your app running in just a few steps.

## Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ deployment target
- macOS Sonoma or later recommended

## Step 1: Clone and Open

```bash
git clone https://github.com/cliffordh/swiftui-indie-stack.git
cd swiftui-indie-stack/ios
open MyApp.xcodeproj
```

## Step 2: Configure Your App

Open `Sources/App/AppConfiguration.swift` and update:

```swift
// Required: Update with your API keys
static let revenueCatAPIKey = "your_revenuecat_key"
static let telemetryDeckAppID = "your_telemetrydeck_id"

// Optional: Enable Firebase
static let useFirebase = false  // Set true if using Firebase
```

## Step 3: Update Bundle Identifier

1. Select the project in Xcode
2. Go to **Signing & Capabilities**
3. Update the **Bundle Identifier** to your own (e.g., `com.yourcompany.yourapp`)
4. Select your **Team**

## Step 4: Run

Press `Cmd + R` to build and run on the simulator.

## Next Steps

### Customize Branding
- Update colors in `Assets.xcassets`
- Modify `AppColors.swift` for your color scheme
- Replace the app icon

### Set Up RevenueCat
1. Create products in App Store Connect
2. Configure offerings in RevenueCat dashboard
3. Add your API key to `AppConfiguration.swift`

### Enable Firebase (Optional)
1. Create a Firebase project
2. Download `GoogleService-Info.plist`
3. Add to Xcode project
4. Set `useFirebase = true`

### Set Up Content Repository
1. Create a GitHub repo for your content
2. Update `libraryIndexURL` in `AppConfiguration.swift`
3. Push your `content/` folder to the repo

## Troubleshooting

### RevenueCat Errors
If you see credential errors, make sure:
- Your API key is correct
- Your products are configured in RevenueCat
- For testing, use Sandbox accounts

### Firebase Issues
- Ensure `GoogleService-Info.plist` is in your project
- Check Firebase console for any configuration issues

### Library Not Loading
- Verify your content repo URL is correct
- Check that `index.json` is valid JSON
- Ensure raw GitHub URLs are used
