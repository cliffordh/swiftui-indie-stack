// swift-tools-version: 5.9
// This file is for reference only - add these packages via Xcode SPM

/*
 Add these packages to your Xcode project via:
 File > Add Package Dependencies...

 Required packages:
 - https://github.com/gonzalezreal/swift-markdown-ui (2.4.0)
 - https://github.com/simibac/ConfettiSwiftUI (1.1.0)
 - https://github.com/markiv/SwiftUI-Shimmer (1.5.0)
 - https://github.com/gonzalezreal/NetworkImage (6.0.0)

 Optional packages (based on AppConfiguration):

 If useRevenueCat = true:
 - https://github.com/RevenueCat/purchases-ios (5.31.0)

 If useTelemetryDeck = true:
 - https://github.com/TelemetryDeck/SwiftSDK (2.9.0)

 If useFirebase = true:
 - https://github.com/firebase/firebase-ios-sdk (11.8.0)
 - https://github.com/google/GoogleSignIn-iOS (8.0.0)
*/

import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MyApp",
            targets: ["MyApp"]
        ),
    ],
    dependencies: [
        // Required
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.4.0"),
        .package(url: "https://github.com/simibac/ConfettiSwiftUI", from: "1.1.0"),
        .package(url: "https://github.com/markiv/SwiftUI-Shimmer", from: "1.5.0"),
        .package(url: "https://github.com/gonzalezreal/NetworkImage", from: "6.0.0"),

        // Optional - RevenueCat
        .package(url: "https://github.com/RevenueCat/purchases-ios", from: "5.31.0"),

        // Optional - TelemetryDeck
        .package(url: "https://github.com/TelemetryDeck/SwiftSDK", from: "2.9.0"),

        // Optional - Firebase (uncomment if useFirebase = true)
        // .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.8.0"),
        // .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "MyApp",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "ConfettiSwiftUI", package: "ConfettiSwiftUI"),
                .product(name: "Shimmer", package: "SwiftUI-Shimmer"),
                .product(name: "NetworkImage", package: "NetworkImage"),
                .product(name: "RevenueCat", package: "purchases-ios"),
                .product(name: "RevenueCatUI", package: "purchases-ios"),
                .product(name: "TelemetryDeck", package: "SwiftSDK"),
                // Uncomment if useFirebase = true:
                // .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                // .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
            ]
        ),
    ]
)
