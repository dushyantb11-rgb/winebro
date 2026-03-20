# WineBro — Deployment & Client Transfer Guide

## Firebase Project Details

| Item | Value |
|------|-------|
| Project ID | `winebro` |
| Project Number | `708385389571` |
| Hosting URL | `winebro.web.app` / `winebro.firebaseapp.com` |
| Firestore Region | `asia-south1` (Mumbai) |
| Android Package | `com.chv.winebro` |
| iOS Bundle ID | `com.chv.winebro` |

## Deploying to This Firebase Project

### Prerequisites
1. Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Node.js 20+

### One-Time Setup
```bash
cd app

# Enable billing (required for Cloud Functions and Firestore rules)
# Visit: https://console.firebase.google.com/project/winebro/settings/billing

# Enable required Firebase services in console:
# - Authentication (Email/Password + Phone)
# - Cloud Firestore (already created in asia-south1)
# - Cloud Messaging
# - Crashlytics
# - Analytics

# Install function dependencies
cd functions && npm install && cd ..
```

### Deploy Everything
```bash
firebase deploy --project winebro
```

### Deploy Individually
```bash
firebase deploy --only firestore:rules --project winebro
firebase deploy --only firestore:indexes --project winebro
firebase deploy --only functions --project winebro
firebase deploy --only hosting --project winebro
```

### Build & Run the App
```bash
flutter pub get
flutter run                  # Debug
flutter build apk --release  # Android APK
flutter build ios --release   # iOS (requires macOS)
```

---

## Transferring to Client's Environment

### Option A: Transfer This Firebase Project (Recommended)

Firebase projects can be transferred between Google accounts:

1. Go to Firebase Console > Project Settings > Users and permissions
2. Add the client's Google account as Owner
3. Client accepts the ownership transfer
4. Remove your account from the project

**What transfers:** Everything — Firestore data, Auth users, Cloud Functions,
Hosting (winebro.web.app), Analytics history, Crashlytics data.

**What stays the same:** App package name, all code, all URLs.

### Option B: Client Creates Their Own Firebase Project

If the client wants a completely separate project:

#### Step 1: Client creates project
```bash
firebase projects:create <their-project-id> --display-name "WineBro"
firebase apps:create android --project <their-project-id> --package-name com.chv.winebro
firebase apps:create ios --project <their-project-id> --bundle-id com.chv.winebro
```

#### Step 2: Download their config files
```bash
# Android
firebase apps:sdkconfig ANDROID <android-app-id> --project <their-project-id> > android/app/google-services.json

# iOS — download GoogleService-Info.plist from Firebase Console
```

#### Step 3: Update .firebaserc
```json
{
  "projects": {
    "default": "<their-project-id>"
  }
}
```

#### Step 4: Create Firestore database
```bash
firebase firestore:databases:create default --project <their-project-id> --location asia-south1
```

#### Step 5: Deploy
```bash
firebase deploy --project <their-project-id>
```

#### What changes:
- `.web.app` subdomain: `<their-project-id>.web.app` (not `winebro.web.app`)
- Config files: New `google-services.json` / `GoogleService-Info.plist`
- `.firebaserc`: Points to their project

#### What stays the same:
- All app code (zero changes)
- Package name: `com.chv.winebro`
- All functionality
- Cloud Functions
- Firestore rules and indexes

#### Custom Domain (Optional):
To keep a consistent URL regardless of project:
```bash
firebase hosting:channel:deploy winebro --project <their-project-id>
# Or add custom domain in Firebase Console > Hosting > Add custom domain
```

---

## Environment Configuration

The app uses Firebase config files for environment switching:

| File | Platform | Location |
|------|----------|----------|
| `google-services.json` | Android | `android/app/` |
| `GoogleService-Info.plist` | iOS | `ios/Runner/` |
| `firebase_options.dart` | Flutter | `lib/` (if using FlutterFire CLI) |

**To switch environments**, replace these files. No code changes needed.

### Generating firebase_options.dart (Alternative to manual config)
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<project-id>
```
This auto-generates `lib/firebase_options.dart` with the correct keys for all platforms.

---

## Checklist Before Client Handoff

- [ ] Enable Blaze billing plan on Firebase project
- [ ] Enable Authentication providers (Email/Password + Phone)
- [ ] Deploy Firestore rules: `firebase deploy --only firestore:rules`
- [ ] Deploy Firestore indexes: `firebase deploy --only firestore:indexes`
- [ ] Deploy Cloud Functions: `firebase deploy --only functions`
- [ ] Deploy Hosting (privacy policy, landing page): `firebase deploy --only hosting`
- [ ] Download real font files (Playfair Display, Montserrat, Lora) into `fonts/`
- [ ] Build and test APK on a physical device
- [ ] Test Phone OTP flow end-to-end
- [ ] Verify Firestore security rules with the rules emulator
- [ ] Set up FCM for push notifications
- [ ] Create Play Store / App Store listings with feature graphic and screenshots
