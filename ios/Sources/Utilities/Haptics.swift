//
//  Haptics.swift
//  MyApp
//
//  Haptic feedback utilities using UIImpactFeedbackGenerator and CoreHaptics.
//

import Foundation
import UIKit
import CoreHaptics

enum Haptics: String, CaseIterable, Identifiable {
    case light
    case medium
    case heavy

    var id: String { rawValue }

    /// Trigger haptic feedback at specified intensity
    static func triggerHapticFeedback(impactLevel: Haptics) {
        let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle

        switch impactLevel {
        case .light:
            feedbackStyle = .light
        case .medium:
            feedbackStyle = .medium
        case .heavy:
            feedbackStyle = .heavy
        }

        let feedbackGenerator = UIImpactFeedbackGenerator(style: feedbackStyle)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }

    /// Trigger notification haptic (success, warning, error)
    static func triggerNotificationHaptic(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    /// Trigger success haptic
    static func success() {
        triggerNotificationHaptic(type: .success)
    }

    /// Trigger warning haptic
    static func warning() {
        triggerNotificationHaptic(type: .warning)
    }

    /// Trigger error haptic
    static func error() {
        triggerNotificationHaptic(type: .error)
    }

    /// Trigger selection changed haptic (light tap)
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
