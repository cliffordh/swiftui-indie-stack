//
//  GoogleSignInManager.swift
//  MyApp
//
//  Handles Google Sign-In flow with session restore.
//

import GoogleSignIn
import UIKit

class GoogleSignInManager {

    static let shared = GoogleSignInManager()

    private init() {}

    /// Sign in with Google, restoring previous session if available
    @MainActor
    func signInWithGoogle() async throws -> GIDGoogleUser? {
        // Check for previous sign-in
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            do {
                try await GIDSignIn.sharedInstance.restorePreviousSignIn()
                return try await GIDSignIn.sharedInstance.currentUser?.refreshTokensIfNeeded()
            } catch {
                // Previous sign in was revoked, initiate new sign-in flow
                return try await googleSignInFlow()
            }
        } else {
            return try await googleSignInFlow()
        }
    }

    /// Present the Google Sign-In flow
    @MainActor
    private func googleSignInFlow() async throws -> GIDGoogleUser? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        return result.user
    }

    /// Sign out from Google
    func signOutFromGoogle() {
        GIDSignIn.sharedInstance.signOut()
    }
}
