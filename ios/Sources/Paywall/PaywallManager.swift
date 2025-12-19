//
//  PaywallManager.swift
//  MyApp
//
//  Manages RevenueCat paywall display and subscription status.
//  Uses RevenueCat's native paywall UI - no custom paywall implementation needed.
//

import SwiftUI
import Combine
import RevenueCat
import RevenueCatUI

class PaywallManager: ObservableObject {

    static let shared = PaywallManager()

    @Published var showPaywall = false
    @Published var isSubscribed = false
    @Published var customerInfo: CustomerInfo?

    @LoggerWrapper(category: "PaywallManager")
    private var log

    private init() {
        // Listen to customer info updates
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            self?.handleCustomerInfoUpdate(customerInfo)
        }
    }

    // MARK: - Subscription Status

    /// Check if user has an active subscription
    func checkSubscriptionStatus() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            let hasActiveEntitlement = !customerInfo.entitlements.active.isEmpty

            await MainActor.run {
                self.isSubscribed = hasActiveEntitlement
                self.customerInfo = customerInfo
            }

            return hasActiveEntitlement
        } catch {
            log.error("Error checking subscription status: \(error)")
            return false
        }
    }

    /// Check if user has a specific entitlement
    func hasEntitlement(_ identifier: String) async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            return customerInfo.entitlements[identifier]?.isActive == true
        } catch {
            log.error("Error checking entitlement: \(error)")
            return false
        }
    }

    // MARK: - Paywall Display

    /// Show paywall if user is not subscribed
    func showPaywallIfNeeded() {
        Task {
            let isSubscribed = await checkSubscriptionStatus()
            if !isSubscribed {
                await MainActor.run {
                    self.showPaywall = true
                    Analytics.track(event: "paywall_shown")
                }
            }
        }
    }

    /// Trigger paywall display
    func triggerPaywall() {
        log.info("Showing paywall")
        showPaywall = true
        Analytics.track(event: "paywall_shown")
    }

    // MARK: - Customer Info Handling

    private func handleCustomerInfoUpdate(_ customerInfo: CustomerInfo?) {
        guard let customerInfo = customerInfo else { return }

        DispatchQueue.main.async {
            self.customerInfo = customerInfo
            self.isSubscribed = !customerInfo.entitlements.active.isEmpty

            if self.isSubscribed {
                Analytics.track(event: "subscription_active")
            }
        }
    }

    // MARK: - Restore Purchases

    /// Restore previous purchases
    func restorePurchases() async throws -> CustomerInfo {
        let customerInfo = try await Purchases.shared.restorePurchases()
        handleCustomerInfoUpdate(customerInfo)
        Analytics.track(event: "purchases_restored")
        return customerInfo
    }
}

// MARK: - Paywall View Modifier

/// View modifier to show RevenueCat's default paywall
struct PaywallPresenter: ViewModifier {
    @ObservedObject var paywallManager = PaywallManager.shared

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $paywallManager.showPaywall) {
                PaywallView()
                    .onRestoreCompleted { customerInfo in
                        debugPrint("Restore completed: \(customerInfo.entitlements.active)")
                    }
            }
    }
}

extension View {
    /// Add paywall presentation capability to any view
    func withPaywall() -> some View {
        modifier(PaywallPresenter())
    }
}
