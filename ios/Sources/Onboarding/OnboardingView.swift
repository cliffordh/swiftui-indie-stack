//
//  OnboardingView.swift
//  MyApp
//
//  Simple onboarding flow for new users.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingDone: Bool

    @State private var currentPage = 0

    // TODO: Customize these for your app
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "SwiftUI Indie Stack",
            description: "A production-ready iOS template. Ship your app in hours, not weeks.",
            imageName: "Mascot",
            useAssetImage: true
        ),
        OnboardingPage(
            title: "Track Your Progress",
            description: "Build habits and maintain your streak with daily activities.",
            imageName: "flame.fill",
            imageColor: .red
        ),
        OnboardingPage(
            title: "Learn & Grow",
            description: "Access our library of guides to customize everything.",
            imageName: "book.fill",
            imageColor: .purple
        )
    ]

    var body: some View {
        VStack {
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))

            // Bottom buttons
            VStack(spacing: 16) {
                if currentPage < pages.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .primaryStyle()
                    .padding(.horizontal, 40)

                    Button("Skip") {
                        completeOnboarding()
                    }
                    .tertiaryStyle()
                } else {
                    Button("Get Started") {
                        completeOnboarding()
                    }
                    .primaryStyle()
                    .padding(.horizontal, 40)
                }
            }
            .padding(.bottom, 40)
        }
        .task {
            Analytics.trackOnboardingStep(0, stepName: "started")
        }
    }

    private func completeOnboarding() {
        Analytics.trackOnboardingStep(pages.count, stepName: "completed")
        isOnboardingDone = true
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let imageColor: Color
    let useAssetImage: Bool  // true = use asset catalog, false = use SF Symbol

    init(title: String, description: String, imageName: String, imageColor: Color = .primary, useAssetImage: Bool = false) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.imageColor = imageColor
        self.useAssetImage = useAssetImage
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            if page.useAssetImage {
                Image(page.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(radius: 4)
            } else {
                Image(systemName: page.imageName)
                    .font(.system(size: 100))
                    .foregroundColor(page.imageColor)
            }

            VStack(spacing: 16) {
                Text(page.title)
                    .font(AppFonts.title)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(AppFonts.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isOnboardingDone: .constant(false))
}
