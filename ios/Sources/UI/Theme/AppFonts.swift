//
//  AppFonts.swift
//  MyApp
//
//  Typography system for consistent text styling throughout the app.
//

import SwiftUI

struct AppFonts {

    // MARK: - Headings

    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title = Font.title.weight(.bold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.semibold)

    // MARK: - Body Text

    static let body = Font.body
    static let bodyBold = Font.body.weight(.semibold)
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2

    // MARK: - Special Styles

    /// Large numbers (scores, counts)
    static func scoreDisplay(size: CGFloat = 48) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    /// Button text
    static let button = Font.body.weight(.semibold)

    /// Tab bar labels
    static let tabLabel = Font.caption2.weight(.medium)

    /// Badge text
    static let badge = Font.caption.weight(.bold)
}

// MARK: - Text Style Modifiers

extension View {

    /// Apply heading style
    func headingStyle() -> some View {
        self
            .font(AppFonts.title2)
            .foregroundColor(AppColors.textPrimary)
    }

    /// Apply body style
    func bodyStyle() -> some View {
        self
            .font(AppFonts.body)
            .foregroundColor(AppColors.textPrimary)
    }

    /// Apply secondary text style
    func secondaryStyle() -> some View {
        self
            .font(AppFonts.subheadline)
            .foregroundColor(AppColors.textSecondary)
    }

    /// Apply caption style
    func captionStyle() -> some View {
        self
            .font(AppFonts.caption)
            .foregroundColor(AppColors.textTertiary)
    }
}
