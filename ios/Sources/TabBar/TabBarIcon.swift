//
//  TabBarIcon.swift
//  MyApp
//
//  Custom tab bar icon with selection state and badge support.
//

import SwiftUI

struct TabBarIcon: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var selectedTab: Int
    let assignedTab: Int
    let systemIconName: String
    let tabName: String
    let color: Color

    var showBadge: Bool = false

    var body: some View {
        Button(action: {
            Haptics.triggerHapticFeedback(impactLevel: .light)
            selectedTab = assignedTab
        }) {
            VStack {
                ZStack {
                    // Selection background
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isSelected ? AppColors.accent.opacity(0.6) : Color.clear,
                            lineWidth: 4
                        )
                        .background(
                            isSelected ?
                                AppColors.accent.opacity(colorScheme == .dark ? 0.2 : 0.1) :
                                Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 42, height: 42)

                    // Icon
                    Image(systemName: systemIconName)
                        .foregroundColor(color)
                        .imageScale(.large)
                        .font(.system(size: 20, weight: .bold))

                    // Badge indicator
                    if showBadge {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .offset(x: 12, y: -12)
                    }
                }
            }
            .frame(height: 50)
            .padding(.top, 5)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(tabName)
        .accessibilityHint("Tab \(assignedTab + 1)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var isSelected: Bool {
        selectedTab == assignedTab
    }
}

#Preview {
    HStack {
        TabBarIcon(
            selectedTab: .constant(0),
            assignedTab: 0,
            systemIconName: "house.fill",
            tabName: "Home",
            color: .orange
        )

        TabBarIcon(
            selectedTab: .constant(0),
            assignedTab: 1,
            systemIconName: "book.fill",
            tabName: "Library",
            color: .purple,
            showBadge: true
        )

        TabBarIcon(
            selectedTab: .constant(0),
            assignedTab: 2,
            systemIconName: "gearshape.fill",
            tabName: "Settings",
            color: .blue
        )
    }
}
