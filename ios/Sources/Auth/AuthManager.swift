//
//  AuthManager.swift
//  MyApp
//
//  Central authentication manager supporting two modes:
//  - Firebase mode: Full auth with Apple/Google Sign-In, anonymous auth, credential linking
//  - Local mode: Device-based identity for RevenueCat/TelemetryDeck without Firebase
//
//  Mode is controlled by AppConfiguration.useFirebase
//

import Foundation
import AuthenticationServices
import SwiftUI
import Combine

#if canImport(Firebase)
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
#endif

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

#if canImport(RevenueCat)
import RevenueCat
#endif

#if canImport(TelemetryDeck)
import TelemetryDeck
#endif

/// Authentication states for the app
enum AuthState {
    /// Anonymously authenticated (Firebase) or local mode
    case authenticated
    /// Authenticated with a sign-in provider (Apple, Google)
    case signedIn
    /// Not authenticated
    case signedOut
}

/// Authentication errors
enum AuthError: Error {
    case noAnonymousUser
    case invalidCredentials
    case firebaseDisabled
    case unknown
}

class AuthManager: ObservableObject {

    static let shared = AuthManager()
    private let firestoreManager = FirestoreManager.shared

    /// Current user ID (Firebase UID or device ID depending on mode)
    var userId: String {
        #if canImport(Firebase)
        if AppConfiguration.useFirebase {
            return user?.uid ?? localUserId
        }
        #endif
        return localUserId
    }

    /// Local device-based user ID for non-Firebase mode
    private var localUserId: String {
        if let storedId = UserDefaults.standard.string(forKey: "localUserId") {
            return storedId
        }
        let newId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        UserDefaults.standard.set(newId, forKey: "localUserId")
        return newId
    }

    #if canImport(Firebase)
    var user: User?
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let db: Firestore?
    #endif

    @Published var authState: AuthState = .signedOut
    @Published var isCheckingAuth: Bool = true

    private init() {
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            #if canImport(Firebase)
            db = nil
            #endif
            isCheckingAuth = false
            return
        }

        #if canImport(Firebase)
        if AppConfiguration.useFirebase {
            db = Firestore.firestore()
            Task {
                await handleSignInValidationAndProviderChecks()
            }
        } else {
            db = nil
            setupLocalMode()
        }
        #else
        setupLocalMode()
        #endif
    }

    /// Setup for local (non-Firebase) mode
    private func setupLocalMode() {
        DispatchQueue.main.async {
            self.authState = .authenticated
            self.isCheckingAuth = false
        }

        // Configure analytics with local user ID
        #if canImport(TelemetryDeck)
        if AppConfiguration.useTelemetryDeck {
            TelemetryDeck.updateDefaultUserID(to: localUserId)
        }
        #endif

        // Configure RevenueCat with local user ID
        #if canImport(RevenueCat)
        if AppConfiguration.useRevenueCat {
            Task {
                do {
                    _ = try await Purchases.shared.logIn(localUserId)
                } catch {
                    debugPrint("Failed to log in to RevenueCat: \(error)")
                }
            }
        }
        #endif
    }

    // MARK: - Initial Authentication

    @MainActor
    func handleInitialAuthentication() async {
        #if canImport(Firebase)
        guard AppConfiguration.useFirebase else {
            setupLocalMode()
            return
        }

        if Auth.auth().currentUser == nil {
            do {
                try await signInAnonymously()
            } catch {
                debugPrint("Error creating anonymous account: \(error)")
            }
        }
        #else
        setupLocalMode()
        #endif
    }

    /// Sign in anonymously for users who haven't created an account yet
    func signInAnonymously() async throws {
        #if canImport(Firebase)
        guard AppConfiguration.useFirebase else {
            throw AuthError.firebaseDisabled
        }

        let result = try await Auth.auth().signInAnonymously()
        debugPrint("Signed in anonymously with user: \(result.user.uid)")
        updateState(user: result.user)
        #else
        throw AuthError.firebaseDisabled
        #endif
    }

    /// Check if current user is anonymous
    var isAnonymous: Bool {
        #if canImport(Firebase)
        if AppConfiguration.useFirebase {
            return Auth.auth().currentUser?.isAnonymous ?? true
        }
        #endif
        return true // Local mode is always "anonymous" in terms of not having a provider
    }

    /// Check if sign-in UI should be shown
    /// Requires both Firebase enabled AND enableAuth flag set
    var canSignIn: Bool {
        AppConfiguration.useFirebase && AppConfiguration.enableAuth
    }

    // MARK: - Auth State Management

    #if canImport(Firebase)
    func configureAuthStateChanges() {
        guard AppConfiguration.useFirebase else { return }

        authStateHandle = Auth.auth().addStateDidChangeListener { _, user in
            self.updateState(user: user)
        }
    }

    func removeAuthStateListener() {
        guard AppConfiguration.useFirebase else { return }

        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    internal func updateState(user: User?) {
        DispatchQueue.main.async {
            self.user = user

            if let user = user {
                // Update analytics user IDs
                #if canImport(TelemetryDeck)
                if AppConfiguration.useTelemetryDeck {
                    TelemetryDeck.updateDefaultUserID(to: user.uid)
                }
                #endif

                // Update RevenueCat user ID
                #if canImport(RevenueCat)
                if AppConfiguration.useRevenueCat {
                    Task {
                        do {
                            _ = try await Purchases.shared.logIn(user.uid)
                            Purchases.shared.attribution.setAttributes([
                                "$telemetryDeckUserId": user.uid,
                                "$telemetryDeckAppId": AppConfiguration.telemetryDeckAppID
                            ])
                        } catch {
                            debugPrint("Failed to log in to RevenueCat: \(error)")
                        }
                    }
                }
                #endif

                if user.isAnonymous {
                    self.authState = .authenticated
                } else {
                    self.authState = .signedIn
                    self.firestoreManager.refreshUserCollection()
                }
            } else {
                self.authState = .signedOut
            }
        }
    }
    #endif

    // MARK: - Sign-In Validation

    #if canImport(Firebase)
    func handleSignInValidationAndProviderChecks() async {
        guard AppConfiguration.useFirebase else {
            setupLocalMode()
            return
        }

        configureAuthStateChanges()

        defer {
            DispatchQueue.main.async {
                self.isCheckingAuth = false
            }
        }

        guard let currentUser = Auth.auth().currentUser else {
            return
        }

        // Validate sign-in
        do {
            try await currentUser.reload()
        } catch {
            debugPrint("User is no longer valid: \(error.localizedDescription)")
            try? Auth.auth().signOut()
            return
        }

        // Verify provider credentials
        await verifySignInProviders(currentUser: currentUser)
    }

    private func verifySignInProviders(currentUser: User) async {
        let providerData = currentUser.providerData

        var isAppleCredentialRevoked = false
        var isGoogleCredentialRevoked = false

        if providerData.contains(where: { $0.providerID == "apple.com" }) {
            isAppleCredentialRevoked = await !verifySignInWithAppleID()
        }

        #if canImport(GoogleSignIn)
        if providerData.contains(where: { $0.providerID == "google.com" }) {
            isGoogleCredentialRevoked = await !verifyGoogleSignIn()
        }
        #endif

        if isAppleCredentialRevoked && isGoogleCredentialRevoked {
            signOut()
        }
    }

    private func verifySignInWithAppleID() async -> Bool {
        let appleIDProvider = ASAuthorizationAppleIDProvider()

        guard let providerData = Auth.auth().currentUser?.providerData,
              let appleProviderData = providerData.first(where: { $0.providerID == "apple.com" }) else {
            return false
        }

        do {
            let credentialState = try await appleIDProvider.credentialState(forUserID: appleProviderData.uid)
            return credentialState != .revoked && credentialState != .notFound
        } catch {
            return false
        }
    }

    #if canImport(GoogleSignIn)
    private func verifyGoogleSignIn() async -> Bool {
        guard let providerData = Auth.auth().currentUser?.providerData,
              providerData.contains(where: { $0.providerID == "google.com" }) else {
            return false
        }

        do {
            try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            return true
        } catch {
            return false
        }
    }
    #endif
    #endif

    // MARK: - Sign Out

    func signOut() {
        #if canImport(Firebase)
        guard AppConfiguration.useFirebase else { return }

        do {
            try Auth.auth().signOut()
            SettingsViewModel.shared.restoreSettings(newSettings: [:])

            // Reset RevenueCat to anonymous
            #if canImport(RevenueCat)
            if AppConfiguration.useRevenueCat {
                Purchases.shared.logOut { _, error in
                    if let error = error {
                        debugPrint("Failed to log out of RevenueCat: \(error)")
                    }
                }
            }
            #endif

            // Reset TelemetryDeck to anonymous
            #if canImport(TelemetryDeck)
            if AppConfiguration.useTelemetryDeck {
                let anonymousID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_user"
                TelemetryDeck.updateDefaultUserID(to: anonymousID)
            }
            #endif

        } catch {
            debugPrint("Failed to sign out: \(error.localizedDescription)")
        }
        #endif
    }

    // MARK: - Anonymous User Linking

    #if canImport(Firebase)
    private func linkAnonymousUser(with credentials: AuthCredential) async throws -> AuthDataResult {
        guard AppConfiguration.useFirebase else {
            throw AuthError.firebaseDisabled
        }

        guard let anonymousUser = Auth.auth().currentUser, anonymousUser.isAnonymous else {
            throw AuthError.noAnonymousUser
        }

        do {
            let result = try await anonymousUser.link(with: credentials)
            await MainActor.run {
                self.updateState(user: result.user)
            }
            return result
        } catch let error as NSError {
            if error.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                // Credentials already in use - sign in with existing account
                if let existingCredential = error.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential {
                    let result = try await Auth.auth().signIn(with: existingCredential)

                    // Migrate anonymous user data
                    await migrateAnonymousUserData(from: anonymousUser.uid, to: result.user.uid)

                    await MainActor.run {
                        self.updateState(user: result.user)
                    }
                    return result
                }
            }
            throw error
        }
    }

    private func migrateAnonymousUserData(from anonymousUID: String, to permanentUID: String) async {
        guard let db = db else { return }

        await withCheckedContinuation { continuation in
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                do {
                    let anonymousRef = db.collection("users").document(anonymousUID)
                    let anonymousDoc = try transaction.getDocument(anonymousRef)
                    guard let anonymousData = anonymousDoc.data() else { return nil }

                    let permanentRef = db.collection("users").document(permanentUID)
                    let permanentDoc = try? transaction.getDocument(permanentRef)
                    var newData = permanentDoc?.data() ?? [:]

                    // Fields to migrate from anonymous account
                    let fieldsToMigrate = [
                        "subscriptionStatus",
                        "subscriptionTier",
                        "settings",
                        "createdAt"
                    ]

                    for field in fieldsToMigrate {
                        if let value = anonymousData[field] {
                            newData[field] = value
                        }
                    }

                    // Add migration metadata
                    newData["migratedFromAnonymous"] = true
                    newData["migrationDate"] = Timestamp(date: Date())
                    newData["previousUID"] = anonymousUID

                    // Add user profile data
                    if let currentUser = Auth.auth().currentUser {
                        newData["email"] = currentUser.email
                        newData["displayName"] = currentUser.displayName
                        newData["photoURL"] = currentUser.photoURL?.absoluteString
                        newData["lastUpdated"] = Timestamp(date: Date())
                    }

                    transaction.setData(newData, forDocument: permanentRef, merge: true)
                    transaction.deleteDocument(anonymousRef)

                    return true
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }) { _, error in
                if let error = error {
                    debugPrint("Error migrating anonymous user data: \(error)")
                }
                continuation.resume()
            }
        }
    }
    #endif

    // MARK: - Google Sign-In

    #if canImport(Firebase) && canImport(GoogleSignIn)
    func googleAuth(_ user: GIDGoogleUser) async throws -> AuthDataResult? {
        guard AppConfiguration.useFirebase else {
            throw AuthError.firebaseDisabled
        }

        guard let idToken = user.idToken?.tokenString else { return nil }

        let credentials = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: user.accessToken.tokenString
        )

        if isAnonymous {
            return try await linkAnonymousUser(with: credentials)
        } else {
            return try await Auth.auth().signIn(with: credentials)
        }
    }
    #endif

    // MARK: - Apple Sign-In

    #if canImport(Firebase)
    func appleAuth(
        _ appleIDCredential: ASAuthorizationAppleIDCredential,
        nonce: String?
    ) async throws -> AuthDataResult? {
        guard AppConfiguration.useFirebase else {
            throw AuthError.firebaseDisabled
        }

        guard let nonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }

        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            return nil
        }

        let credentials = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        if isAnonymous {
            return try await linkAnonymousUser(with: credentials)
        } else {
            return try await Auth.auth().signIn(with: credentials)
        }
    }
    #endif
}
