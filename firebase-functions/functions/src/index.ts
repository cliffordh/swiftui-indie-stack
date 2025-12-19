/**
 * Firebase Cloud Functions for MyApp
 *
 * Functions:
 * - createUserRecord: Creates user document on auth signup
 * - updateStreak: Calculates and updates user streak data
 * - sendStreakReminder: Sends push notification for at-risk streaks
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();

// ============================================================================
// USER MANAGEMENT
// ============================================================================

/**
 * Create user record in Firestore when a new user signs up
 */
export const createUserRecord = functions.auth.user().onCreate(async (user) => {
  const userRecord = {
    uid: user.uid,
    email: user.email || null,
    displayName: user.displayName || null,
    photoURL: user.photoURL || null,
    emailVerified: user.emailVerified || false,
    phoneNumber: user.phoneNumber || null,
    disabled: user.disabled || false,

    // Metadata
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    modifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    lastLoginAt: null,

    // Provider data
    providerData: user.providerData || [],

    // Streak data (initialized)
    streak: {
      currentStreak: 0,
      bestStreak: 0,
      lastActivityDate: null,
      streakStartDate: null,
      isAtRisk: false,
      freezesAvailable: 0,
      freezeActive: false,
      activeDays: [],
    },

    // Settings
    settings: {
      notificationsEnabled: false,
      streakReminderEnabled: true,
    },
  };

  await db.collection("users").doc(user.uid).set(userRecord, { merge: true });
  console.log(`Created user record for ${user.uid}`);
});

// ============================================================================
// STREAK MANAGEMENT
// ============================================================================

/**
 * Calculate and update streak for a user
 * Called when activity is logged or on a schedule
 */
export const updateStreak = functions.firestore
  .document("users/{userId}/activity/{activityId}")
  .onCreate(async (snap, context) => {
    const userId = context.params.userId;
    const activityData = snap.data();

    if (!activityData) return;

    const userRef = db.collection("users").doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      console.log(`User ${userId} not found`);
      return;
    }

    const userData = userDoc.data();
    const currentStreak = userData?.streak || {};
    const activityDate = activityData.date?.toDate() || new Date();

    // Calculate new streak
    const newStreakData = calculateStreak(currentStreak, activityDate);

    // Update user document
    await userRef.update({
      "streak.currentStreak": newStreakData.currentStreak,
      "streak.bestStreak": newStreakData.bestStreak,
      "streak.lastActivityDate": admin.firestore.Timestamp.fromDate(activityDate),
      "streak.streakStartDate": newStreakData.streakStartDate
        ? admin.firestore.Timestamp.fromDate(newStreakData.streakStartDate)
        : null,
      "streak.isAtRisk": false,
      "streak.activeDays": admin.firestore.FieldValue.arrayUnion(
        admin.firestore.Timestamp.fromDate(getStartOfDay(activityDate))
      ),
      modifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(
      `Updated streak for user ${userId}: ${newStreakData.currentStreak} days`
    );
  });

/**
 * Daily scheduled function to check for at-risk streaks
 * Runs at 6 PM local time to remind users to maintain their streak
 */
export const checkStreaksAtRisk = functions.pubsub
  .schedule("0 18 * * *") // 6 PM daily
  .timeZone("America/New_York") // TODO: Adjust timezone
  .onRun(async () => {
    const today = getStartOfDay(new Date());
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    // Find users with active streaks who haven't logged activity today
    const usersSnapshot = await db
      .collection("users")
      .where("streak.currentStreak", ">", 0)
      .where("settings.streakReminderEnabled", "==", true)
      .get();

    const batch = db.batch();
    const usersToNotify: string[] = [];

    for (const doc of usersSnapshot.docs) {
      const userData = doc.data();
      const lastActivity = userData.streak?.lastActivityDate?.toDate();

      if (lastActivity) {
        const lastActivityDay = getStartOfDay(lastActivity);

        // If last activity was yesterday (not today), streak is at risk
        if (lastActivityDay.getTime() === yesterday.getTime()) {
          batch.update(doc.ref, { "streak.isAtRisk": true });
          usersToNotify.push(doc.id);
        }
      }
    }

    await batch.commit();
    console.log(`Marked ${usersToNotify.length} streaks as at-risk`);

    // TODO: Send push notifications to users at risk
    // This requires FCM tokens stored in user documents
  });

/**
 * Daily scheduled function to reset broken streaks
 * Runs at midnight to reset streaks that weren't maintained
 */
export const resetBrokenStreaks = functions.pubsub
  .schedule("0 0 * * *") // Midnight daily
  .timeZone("America/New_York") // TODO: Adjust timezone
  .onRun(async () => {
    const today = getStartOfDay(new Date());
    const twoDaysAgo = new Date(today);
    twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);

    // Find users with active streaks whose last activity was 2+ days ago
    const usersSnapshot = await db
      .collection("users")
      .where("streak.currentStreak", ">", 0)
      .get();

    const batch = db.batch();
    let resetCount = 0;

    for (const doc of usersSnapshot.docs) {
      const userData = doc.data();
      const lastActivity = userData.streak?.lastActivityDate?.toDate();

      if (lastActivity) {
        const lastActivityDay = getStartOfDay(lastActivity);

        // If last activity was 2+ days ago, reset streak (unless freeze is active)
        if (
          lastActivityDay.getTime() <= twoDaysAgo.getTime() &&
          !userData.streak?.freezeActive
        ) {
          batch.update(doc.ref, {
            "streak.currentStreak": 0,
            "streak.streakStartDate": null,
            "streak.isAtRisk": false,
            "streak.activeDays": [],
          });
          resetCount++;
        }
      }
    }

    await batch.commit();
    console.log(`Reset ${resetCount} broken streaks`);
  });

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

interface StreakData {
  currentStreak: number;
  bestStreak: number;
  lastActivityDate: Date | null;
  streakStartDate: Date | null;
}

function calculateStreak(
  currentStreak: any,
  activityDate: Date
): StreakData {
  const today = getStartOfDay(activityDate);
  const lastActivity = currentStreak.lastActivityDate?.toDate
    ? currentStreak.lastActivityDate.toDate()
    : null;

  let newCurrentStreak = currentStreak.currentStreak || 0;
  let newBestStreak = currentStreak.bestStreak || 0;
  let streakStartDate = currentStreak.streakStartDate?.toDate
    ? currentStreak.streakStartDate.toDate()
    : null;

  if (!lastActivity) {
    // First activity ever
    newCurrentStreak = 1;
    streakStartDate = today;
  } else {
    const lastActivityDay = getStartOfDay(lastActivity);
    const daysDiff = Math.floor(
      (today.getTime() - lastActivityDay.getTime()) / (1000 * 60 * 60 * 24)
    );

    if (daysDiff === 0) {
      // Same day - no change to streak count
    } else if (daysDiff === 1) {
      // Consecutive day - increment streak
      newCurrentStreak += 1;
    } else {
      // Streak broken - start new streak
      newCurrentStreak = 1;
      streakStartDate = today;
    }
  }

  // Update best streak if current is higher
  if (newCurrentStreak > newBestStreak) {
    newBestStreak = newCurrentStreak;
  }

  return {
    currentStreak: newCurrentStreak,
    bestStreak: newBestStreak,
    lastActivityDate: activityDate,
    streakStartDate: streakStartDate,
  };
}

function getStartOfDay(date: Date): Date {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  return d;
}
