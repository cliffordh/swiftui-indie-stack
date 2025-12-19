//
//  AppColors.swift
//  MyApp
//
//  Centralized color definitions for easy theming.
//  Change colors here to re-theme the entire app.
//
//  Default palette inspired by Duolingo's vibrant, friendly aesthetic.
//

import SwiftUI

// MARK: - App Colors

struct AppColors {

    // MARK: - Primary Palette

    /// Primary action color (buttons, links)
    /// Default: Duolingo green
    static let primary = Color("PrimaryGreen")

    /// Secondary action color
    static let secondary = Color("PrimaryBlue")

    /// Accent color for highlights
    static let accent = Color("AccentOrange")

    /// Success/positive color
    static let success = Color("SuccessGreen")

    /// Warning color
    static let warning = Color("WarningYellow")

    /// Error/danger color
    static let error = Color("ErrorRed")

    /// Premium/special features
    static let premium = Color("PremiumPurple")

    // MARK: - Streak Colors

    /// Streak flame color (active)
    static let streakActive = Color.orange

    /// Streak flame color (inactive)
    static let streakInactive = Color.gray

    // MARK: - Semantic Colors

    /// Primary background
    static let backgroundPrimary = Color(.systemBackground)

    /// Secondary background (cards, sections)
    static let backgroundSecondary = Color(.secondarySystemBackground)

    /// Tertiary background
    static let backgroundTertiary = Color(.tertiarySystemBackground)

    /// Primary text color
    static let textPrimary = Color.primary

    /// Secondary text color
    static let textSecondary = Color.secondary

    /// Tertiary text color
    static let textTertiary = Color(.tertiaryLabel)

    // MARK: - Tab Bar Colors

    static let tabHome = Color("TabHome")
    static let tabLibrary = Color("TabLibrary")
    static let tabSettings = Color("TabSettings")

    // MARK: - Dividers and Borders

    static let divider = Color(.separator)
    static let border = Color(.opaqueSeparator)
}

// MARK: - Color Extensions

extension Color {

    /// Initialize color from hex string
    /// Example: Color(hex: "#FF5733") or Color(hex: "FF5733")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Fallback Colors (for when asset colors aren't configured)

extension AppColors {

    /// Fallback colors using hex values
    /// Use these if you haven't set up color assets yet
    struct Fallback {
        static let primaryGreen = Color(hex: "#58CC02")   // Duolingo green
        static let primaryBlue = Color(hex: "#1CB0F6")    // Progress blue
        static let accentOrange = Color(hex: "#FF9600")   // Accent orange
        static let successGreen = Color(hex: "#58CC02")   // Success
        static let warningYellow = Color(hex: "#FFC800")  // Warning
        static let errorRed = Color(hex: "#FF4B4B")       // Error
        static let premiumPurple = Color(hex: "#CE82FF")  // Premium
    }
}
