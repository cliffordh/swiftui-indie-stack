# SwiftUI Indie Stack - Firebase Functions

Backend functions for SwiftUI Indie Stack. These functions handle:

- **User Management**: Create user records on signup
- **Streak Calculation**: Calculate and update streaks when activity is logged
- **Streak Reminders**: Daily checks for at-risk streaks
- **Streak Reset**: Daily cleanup of broken streaks

## Prerequisites

- Node.js 18+
- Firebase CLI (`npm install -g firebase-tools`)
- Firebase project with Firestore enabled

## Setup

### 1. Configure Firebase CLI

```bash
# Login to Firebase
firebase login

# Select your project
firebase use your-project-id
```

### 2. Update Project ID

Edit `.firebaserc` and replace `your-project-id` with your actual Firebase project ID.

### 3. Install Dependencies

```bash
cd functions
npm install
```

### 4. Deploy

```bash
npm run deploy
```

## Local Development

### Start Emulators

```bash
npm run serve
```

This starts the Firebase emulators for local testing.

### View Logs

```bash
npm run logs
```

## Functions

### `createUserRecord`

**Trigger**: Firebase Auth user creation

Creates a user document in Firestore with initial streak data and settings.

### `updateStreak`

**Trigger**: Document creation in `users/{userId}/activity/{activityId}`

Calculates and updates the user's streak based on activity logs.

### `checkStreaksAtRisk`

**Trigger**: Scheduled (6 PM daily)

Marks streaks as "at risk" for users who haven't logged activity today.

### `resetBrokenStreaks`

**Trigger**: Scheduled (midnight daily)

Resets streaks for users who missed 2+ days of activity.

## Firestore Structure

```
users/
  {userId}/
    - uid
    - email
    - displayName
    - streak/
        - currentStreak
        - bestStreak
        - lastActivityDate
        - streakStartDate
        - isAtRisk
        - freezesAvailable
        - freezeActive
        - activeDays[]
    - settings/
        - notificationsEnabled
        - streakReminderEnabled
    activity/
      {activityId}/
        - type
        - timestamp
        - date
```

## Customization

### Change Reminder Time

Edit `checkStreaksAtRisk` schedule in `index.ts`:

```typescript
.schedule("0 18 * * *")  // Change to your preferred time (cron format)
.timeZone("America/New_York")  // Change to your timezone
```

### Change Streak Reset Time

Edit `resetBrokenStreaks` schedule in `index.ts`:

```typescript
.schedule("0 0 * * *")  // Change to your preferred time (cron format)
.timeZone("America/New_York")  // Change to your timezone
```

## Separating as Its Own Repository

This directory is designed to be extracted as a separate git repository:

```bash
# From swiftui-indie-stack root
cd firebase-functions
git init
git add .
git commit -m "Initial commit: Firebase functions"
git remote add origin https://github.com/YOUR_ORG/your-app-functions.git
git push -u origin main
```
