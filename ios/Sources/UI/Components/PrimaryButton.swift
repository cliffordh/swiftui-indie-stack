//
//  PrimaryButton.swift
//  MyApp
//
//  Primary and secondary button styles for the app.
//

import SwiftUI

// MARK: - Primary Button Style

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.button)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? AppColors.primary : Color.gray)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.button)
            .foregroundColor(AppColors.primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.primary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Tertiary Button Style (Text-only)

struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.button)
            .foregroundColor(AppColors.primary)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Convenience Extensions

extension Button {

    /// Apply primary button styling
    func primaryStyle(isEnabled: Bool = true) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
    }

    /// Apply secondary button styling
    func secondaryStyle() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }

    /// Apply tertiary button styling
    func tertiaryStyle() -> some View {
        self.buttonStyle(TertiaryButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Button("Primary Button") {}
            .primaryStyle()

        Button("Secondary Button") {}
            .secondaryStyle()

        Button("Tertiary Button") {}
            .tertiaryStyle()

        Button("Disabled Button") {}
            .primaryStyle(isEnabled: false)
            .disabled(true)
    }
    .padding()
}
