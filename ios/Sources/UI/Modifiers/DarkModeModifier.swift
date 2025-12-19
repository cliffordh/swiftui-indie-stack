//
//  DarkModeModifier.swift
//  MyApp
//
//  View modifier to apply user's preferred appearance (light/dark/system).
//

import SwiftUI

struct DarkModeViewModifier: ViewModifier {
    @AppStorage("appearance") var appearance: Appearance = .system

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(colorScheme)
    }

    private var colorScheme: ColorScheme? {
        switch appearance {
        case .system:
            return nil  // Follow system setting
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

extension View {
    /// Apply user's preferred color scheme
    func applyAppearance() -> some View {
        modifier(DarkModeViewModifier())
    }
}
