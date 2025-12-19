//
//  FirestoreManager.swift
//  MyApp
//
//  Manages Firestore user data and settings synchronization.
//  Only active when AppConfiguration.useFirebase is enabled.
//
//  Offline-first: All methods safely return early when Firebase is disabled.
//

import Foundation

#if canImport(Firebase)
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
#endif

class FirestoreManager {

    static let shared = FirestoreManager()

    #if canImport(Firebase)
    private let db: Firestore?
    #endif
    private var debounceTimer: Timer?

    private init() {
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            #if canImport(Firebase)
            db = nil
            #endif
            return
        }

        #if canImport(Firebase)
        if AppConfiguration.useFirebase {
            db = Firestore.firestore()
        } else {
            db = nil
        }
        #endif
    }

    /// Check if Firestore is available and enabled
    var isAvailable: Bool {
        guard AppConfiguration.useFirebase else { return false }
        #if canImport(Firebase)
        return db != nil
        #else
        return false
        #endif
    }

    // MARK: - User Collection Management

    /// Refresh user data from Firestore after authentication
    func refreshUserCollection() {
        guard AppConfiguration.useFirebase else { return }

        #if canImport(Firebase)
        guard let user = Auth.auth().currentUser else { return }
        guard let db = db else { return }

        let userRef = db.collection("users").document(user.uid)

        userRef.getDocument { documentSnapshot, error in
            guard let document = documentSnapshot, document.exists else {
                debugPrint("User document does not exist")
                return
            }

            var dataToUpdate = [String: Any]()
            let currentData = document.data()

            // Restore settings from Firestore
            let settingsData = currentData?["settings"] as? [String: Any] ?? [:]
            SettingsViewModel.shared.restoreSettings(newSettings: settingsData)

            // Update streak data (read from Firestore - backend manages streak logic)
            if let streakData = currentData?["streak"] as? [String: Any] {
                StreakDataProvider.shared.updateFromFirestore(streakData)
            }

            // Increment usage count once per day
            if let lastUsageDate = currentData?["lastUsageDate"] as? Timestamp {
                if !Calendar.current.isDateInToday(lastUsageDate.dateValue()) {
                    dataToUpdate["lastUsageDate"] = FieldValue.serverTimestamp()
                }
            } else {
                dataToUpdate["lastUsageDate"] = FieldValue.serverTimestamp()
            }

            // Update settings
            dataToUpdate["settings"] = SettingsViewModel.shared.getSettings()

            // Update display name if not set
            if let firestoreDisplayName = currentData?["displayName"] as? String {
                if firestoreDisplayName.isEmpty {
                    dataToUpdate["displayName"] = user.displayName ?? NSNull()
                }
            } else {
                dataToUpdate["displayName"] = user.displayName ?? NSNull()
            }

            // Update photo URL if available
            if let newPhotoURL = user.photoURL?.absoluteString {
                dataToUpdate["photoURL"] = newPhotoURL
            }

            // Update last login timestamp
            dataToUpdate["lastLoginAt"] = FieldValue.serverTimestamp()

            // Update provider data
            let providerData = user.providerData.map { provider -> [String: Any] in
                [
                    "providerId": provider.providerID,
                    "email": provider.email ?? NSNull(),
                    "uid": provider.uid
                ]
            }
            dataToUpdate["providerData"] = providerData

            // Perform update
            userRef.updateData(dataToUpdate) { error in
                if let error = error {
                    debugPrint("Error updating user document: \(error.localizedDescription)")
                } else {
                    debugPrint("User document successfully updated")
                }
            }
        }
        #endif
    }

    // MARK: - Settings Persistence

    /// Save user settings to Firestore with debouncing
    func saveUserSettings(settingsData: [String: Any]) {
        guard AppConfiguration.useFirebase else { return }

        #if canImport(Firebase)
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let db = db else { return }

        db.collection("users").document(userId).setData(
            ["settings": settingsData],
            merge: true
        ) { error in
            if let error = error {
                debugPrint("Error updating settings in Firestore: \(error.localizedDescription)")
            } else {
                debugPrint("Settings updated successfully in Firestore")
            }
        }
        #endif
    }

    /// Get user settings from Firestore
    func getUserSettings() async -> [String: Any] {
        guard AppConfiguration.useFirebase else { return [:] }

        #if canImport(Firebase)
        guard let userId = Auth.auth().currentUser?.uid else {
            return [:]
        }
        guard let db = db else { return [:] }

        do {
            let documentSnapshot = try await db.collection("users").document(userId).getDocument()

            if let settingsData = documentSnapshot.data()?["settings"] as? [String: Any] {
                return settingsData
            } else {
                return [:]
            }
        } catch {
            debugPrint("Error fetching user settings: \(error.localizedDescription)")
            return [:]
        }
        #else
        return [:]
        #endif
    }

    // MARK: - Activity Logging (for streak calculation on backend)

    /// Log user activity - backend will use this to calculate streaks
    func logActivity(type: String = "app_open") {
        guard AppConfiguration.useFirebase else { return }

        #if canImport(Firebase)
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let db = db else { return }

        let activityRef = db.collection("users").document(userId)
            .collection("activity").document()

        let activityData: [String: Any] = [
            "type": type,
            "timestamp": FieldValue.serverTimestamp(),
            "date": Timestamp(date: Calendar.current.startOfDay(for: Date()))
        ]

        activityRef.setData(activityData) { error in
            if let error = error {
                debugPrint("Error logging activity: \(error.localizedDescription)")
            }
        }
        #endif
    }
}
