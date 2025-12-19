# RevenueCat Subscriptions

SwiftUI Indie Stack includes pre-integrated RevenueCat for in-app purchases and subscriptions.

## Setup

### 1. Create RevenueCat Account
Sign up at [revenuecat.com](https://www.revenuecat.com) and create a new project.

### 2. Configure App Store Connect
1. Create your subscription products in App Store Connect
2. Set up a Sandbox tester account for testing

### 3. Add Products to RevenueCat
1. Go to your RevenueCat project
2. Add your App Store app
3. Configure your products and offerings

### 4. Add API Key
Update `AppConfiguration.swift`:

```swift
static let revenueCatAPIKey = "appl_YourActualAPIKey"
```

## Using the Paywall

### Show Paywall Programmatically

```swift
// From anywhere in your app
PaywallManager.shared.triggerPaywall()
```

### Check Subscription Status

```swift
// Async check
let isSubscribed = await PaywallManager.shared.checkSubscriptionStatus()

// Observed property
@ObservedObject var paywallManager = PaywallManager.shared

if paywallManager.isSubscribed {
    // Show premium content
}
```

### Check Specific Entitlements

```swift
let hasPro = await PaywallManager.shared.hasEntitlement("pro")
```

## Customizing the Paywall

RevenueCat provides a native paywall UI that you configure in their dashboard:

1. Go to RevenueCat Dashboard > Paywalls
2. Design your paywall using their visual editor
3. The app automatically uses your configured design

## Restore Purchases

```swift
Button("Restore Purchases") {
    Task {
        try? await PaywallManager.shared.restorePurchases()
    }
}
```

## Testing

### Sandbox Testing
1. Sign out of App Store on device
2. Use Sandbox tester credentials
3. Purchases won't charge real money

### StoreKit Configuration (Xcode)
For faster iteration:
1. Create a StoreKit Configuration file
2. Test purchases without App Store Connect

## Analytics Integration

If TelemetryDeck is enabled, RevenueCat events are automatically linked:

```swift
Purchases.shared.attribution.setAttributes([
    "$telemetryDeckUserId": deviceId,
    "$telemetryDeckAppId": AppConfiguration.telemetryDeckAppID
])
```

## Disabling RevenueCat

To build without subscription features:

```swift
static let useRevenueCat = false
```

The paywall button will be hidden and related code won't execute.
