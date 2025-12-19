//
//  MainTabView.swift
//  MyApp
//
//  Custom tab bar with styled icons and content switching.
//

import SwiftUI

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Content views - keep all views alive to preserve state
            ZStack {
                HomeView()
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 0)

                LibraryView()
                    .opacity(selectedTab == 1 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 1)

                SettingsView()
                    .opacity(selectedTab == 2 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 2)
            }

            // Tab bar separator
            Divider()

            // Custom Tab bar
            HStack {
                Spacer(minLength: 0)

                TabBarIcon(
                    selectedTab: $selectedTab,
                    assignedTab: 0,
                    systemIconName: "house.fill",
                    tabName: "Home",
                    color: AppColors.tabHome
                )

                Spacer(minLength: 0)

                TabBarIcon(
                    selectedTab: $selectedTab,
                    assignedTab: 1,
                    systemIconName: "book.fill",
                    tabName: "Library",
                    color: AppColors.tabLibrary
                )

                Spacer(minLength: 0)

                TabBarIcon(
                    selectedTab: $selectedTab,
                    assignedTab: 2,
                    systemIconName: "gearshape.fill",
                    tabName: "Settings",
                    color: AppColors.tabSettings
                )

                Spacer(minLength: 0)
            }
            .background(AppColors.backgroundPrimary)
            .padding(.bottom, 5)
        }
        .task {
            Analytics.trackScreenView("MainTabView")

            // Mark app usage for streak tracking
            SettingsViewModel.shared.markAppUsage()
        }
        .withPaywall()
    }
}

// MARK: - Placeholder Views (Replace with your implementations)

struct HomeView: View {
    @ObservedObject var streakProvider = StreakDataProvider.shared
    @State private var showGoalCompleted = false

    /// Check if goal was already completed today
    private var goalCompletedToday: Bool {
        guard let lastActivity = streakProvider.streakData.lastActivityDate else {
            return false
        }
        return Calendar.current.isDateInToday(lastActivity)
    }

    /// Auth status detail text for Feature Status panel
    private var authDetailText: String {
        if !AppConfiguration.useFirebase {
            return "Local ID"
        } else if AppConfiguration.enableAuth {
            return "Apple/Google"
        } else {
            return "Anonymous"
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App mascot (placeholder - replace with your own)
                    Image("Mascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(radius: 4)
                        .padding(.top)

                    // Welcome header
                    VStack(spacing: 8) {
                        Text("Welcome to")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("MyApp")
                            .font(AppFonts.title)
                        Text("See the Library tab for customization guides")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    // Streak at risk banner
                    if AppConfiguration.enableStreaks {
                        StreakAtRiskBanner()
                            .padding(.horizontal)
                    }

                    // Complete Goal button (demo for streak increment)
                    if AppConfiguration.enableStreaks {
                        Button {
                            completeGoal()
                        } label: {
                            Label(
                                goalCompletedToday ? "Goal Completed Today!" : "Complete Goal",
                                systemImage: goalCompletedToday ? "checkmark.circle.fill" : "target"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(goalCompletedToday ? .green : .orange)
                        .disabled(goalCompletedToday)
                        .padding(.horizontal)
                    }

                    Divider()
                        .padding(.horizontal)

                    // Feature Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Feature Status")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        FeatureStatusRow(
                            name: "Firebase",
                            enabled: AppConfiguration.useFirebase,
                            icon: "cloud.fill"
                        )
                        FeatureStatusRow(
                            name: "Auth",
                            enabled: AppConfiguration.enableAuth,
                            icon: "person.badge.key.fill",
                            detail: authDetailText
                        )
                        FeatureStatusRow(
                            name: "RevenueCat",
                            enabled: AppConfiguration.useRevenueCat,
                            icon: "creditcard.fill"
                        )
                        FeatureStatusRow(
                            name: "TelemetryDeck",
                            enabled: AppConfiguration.useTelemetryDeck,
                            icon: "chart.bar.fill"
                        )
                        FeatureStatusRow(
                            name: "Streaks",
                            enabled: AppConfiguration.enableStreaks,
                            icon: "flame.fill",
                            detail: streakProvider.hasStreak ? "\(streakProvider.streakData.currentStreak) days" : nil
                        )
                        FeatureStatusRow(
                            name: "Library/CMS",
                            enabled: AppConfiguration.enableLibrary,
                            icon: "book.fill"
                        )
                        FeatureStatusRow(
                            name: "Widgets",
                            enabled: AppConfiguration.enableWidgets,
                            icon: "square.grid.2x2.fill"
                        )
                        FeatureStatusRow(
                            name: "App Review",
                            enabled: AppConfiguration.enableAppReview,
                            icon: "star.fill",
                            detail: "at \(AppConfiguration.appReviewStreakThreshold)-day streak"
                        )
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    Spacer(minLength: 20)

                    // Demo: Show how to trigger paywall programmatically
                    if AppConfiguration.useRevenueCat {
                        Button {
                            PaywallManager.shared.triggerPaywall()
                        } label: {
                            Label("Show Paywall Demo", systemImage: "creditcard.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Home")
            .toolbar {
                if AppConfiguration.enableStreaks {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        CompactStreakBadge()
                    }
                }
            }
        }
    }

    private func completeGoal() {
        // Record activity for streak (works in both local and Firebase mode)
        if AppConfiguration.useFirebase {
            #if canImport(Firebase)
            FirestoreManager.shared.logActivity(type: "goal_completed")
            #endif
        } else {
            streakProvider.recordLocalActivity()
        }

        showGoalCompleted = true
        Analytics.track(event: "goal_completed")
    }
}

// MARK: - Feature Status Row

struct FeatureStatusRow: View {
    let name: String
    let enabled: Bool
    let icon: String
    var detail: String? = nil

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(enabled ? .green : .secondary)
                .frame(width: 24)

            Text(name)
                .foregroundColor(.primary)

            Spacer()

            if let detail = detail {
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)
            }

            Image(systemName: enabled ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundColor(enabled ? .green : .secondary)
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @AppStorage("appearance") var appearance: Appearance = .system

    var body: some View {
        NavigationView {
            List {
                // Account Section
                Section("Account") {
                    if authManager.authState == .signedIn {
                        #if canImport(FirebaseAuth)
                        if let email = authManager.user?.email {
                            HStack {
                                Text("Email")
                                Spacer()
                                Text(email)
                                    .foregroundColor(.secondary)
                            }
                        }
                        #endif

                        Button("Sign Out", role: .destructive) {
                            authManager.signOut()
                        }
                    } else if authManager.canSignIn {
                        NavigationLink("Sign In") {
                            LoginView()
                        }
                    }
                }

                // Appearance Section
                Section("Appearance") {
                    Picker("Theme", selection: $appearance) {
                        ForEach(Appearance.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }

                // Subscription Section
                Section("Subscription") {
                    Button("Manage Subscription") {
                        PaywallManager.shared.triggerPaywall()
                    }

                    Button("Restore Purchases") {
                        Task {
                            try? await PaywallManager.shared.restorePurchases()
                        }
                    }
                }

                // About Section
                Section("About") {
                    Link("Terms of Service", destination: URL(string: AppConfiguration.termsOfServiceURL)!)
                    Link("Privacy Policy", destination: URL(string: AppConfiguration.privacyPolicyURL)!)
                }

                // Template Credit (feel free to remove when customizing)
                Section {
                    Link(destination: URL(string: "https://github.com/cliffordh/swiftui-indie-stack")!) {
                        HStack {
                            Text("Built with SwiftUI Indie Stack")
                                .font(.footnote)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.footnote)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .task {
            Analytics.trackScreenView("SettingsView")
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager.shared)
}
