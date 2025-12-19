//
//  CardView.swift
//  MyApp
//
//  Reusable card component for content containers.
//

import SwiftUI

struct CardView<Content: View>: View {
    let content: Content

    var backgroundColor: Color = AppColors.backgroundSecondary
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 16
    var shadow: Bool = false

    init(
        backgroundColor: Color = AppColors.backgroundSecondary,
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 16,
        shadow: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.shadow = shadow
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .if(shadow) { view in
                view.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
    }
}

// MARK: - Conditional View Modifier

extension View {
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Card Styles

extension CardView {

    /// Standard card with default styling
    static func standard<C: View>(@ViewBuilder content: () -> C) -> CardView<C> {
        CardView<C>(content: content)
    }

    /// Elevated card with shadow
    static func elevated<C: View>(@ViewBuilder content: () -> C) -> CardView<C> {
        CardView<C>(shadow: true, content: content)
    }

    /// Outlined card with border
    static func outlined<C: View>(@ViewBuilder content: () -> C) -> some View {
        CardView<C>(backgroundColor: .clear, content: content)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.border, lineWidth: 1)
            )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Standard Card")
                    .font(.headline)
                Text("This is a standard card with default styling.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }

        CardView(shadow: true) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Elevated Card")
                    .font(.headline)
                Text("This card has a subtle shadow for elevation.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    .padding()
}
