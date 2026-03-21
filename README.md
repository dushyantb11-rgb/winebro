# WineBro

Your elder brother in the world of wine, spirits & food pairing.

WineBro is an alcohol education and food pairing companion app built with Flutter. It helps users discover perfect pairings backed by flavor science through personalized recommendations, label scanning, and structured tasting journals.

## Features

- **Palate Quiz** - 6-axis taste profile generation from food & drink preferences
- **Smart Pairing Engine** - Food-to-drink, drink-to-food, and occasion-based pairing with match percentages
- **Label Scanner** - ML Kit text recognition to identify wine & spirit labels from camera
- **Tasting Journal** - Structured BroCard notes (appearance, nose, palate, finish, rating)
- **Aroma Wheel** - Interactive 6-category aroma taxonomy explorer
- **Gamification** - XP, levels, badges, streaks, and challenges
- **Community** - Brotherhood social features (Phase 2)
- **Multi-language** - English, Hindi, Marathi, Gujarati

## Tech Stack

- **Framework:** Flutter 3.32+
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **Backend:** Firebase (Auth, Firestore, Analytics, Crashlytics, Cloud Functions)
- **ML:** Google ML Kit Text Recognition
- **Charts:** fl_chart (radar chart for palate profiles)

## Project Structure

```
lib/
  app.dart                          # App root with theme + locale
  main.dart                         # Entry point with Firebase init
  core/
    constants/pairing_constants.dart # Palate axes, archetypes, badges, occasions
    providers/                       # Theme + locale providers
    router/app_router.dart           # GoRouter with auth-based redirects
    theme/                           # Light + dark theme, colors, icons
    utils/                           # Validators, formatters
  features/
    auth/                            # Phone OTP + Google Sign-In
    onboarding/                      # Palate quiz engine + UI
    home/                            # Bro's Pick, quick actions, trending
    pairing/                         # Pairing engine, products, dishes
    scanner/                         # Label scanning + search
    journal/                         # Tasting journal + BroCard entry
    aroma_wheel/                     # Aroma taxonomy explorer
    community/                       # Phase 2 placeholder
    profile/                         # Gamification stats, palate radar
  shared/widgets/                    # Reusable UI components
```

## Setup

```bash
flutter pub get
```

### Android

Requires `android/key.properties` and `android/app/winebro-release.jks` for release builds (not in repo).

```bash
flutter run                    # debug
flutter build appbundle        # release AAB for Play Store
```

### iOS

```bash
cd ios && pod install && cd ..
flutter build ipa --export-options-plist=ios/Runner/ExportOptions.plist
```

iOS release builds run via GitHub Actions (`.github/workflows/ios-release.yml`).

### Firebase

```bash
cd functions && npm install && npm run build && cd ..
firebase deploy --only firestore:rules
firebase deploy --only functions
```

## Configuration

| Item | Location |
|------|----------|
| Firebase Android | `android/app/google-services.json` |
| Firebase iOS | `ios/Runner/GoogleService-Info.plist` |
| Firebase options | `lib/firebase_options.dart` |
| Android signing | `android/key.properties` (not in repo) |
| App icon config | `pubspec.yaml` (flutter_launcher_icons section) |

## Brand

- **Parent Company:** Culinary Happiness Ventures (CHV)
- **Primary Color:** Paprika `#93003C`
- **Dark Color:** Thunder `#252122`
- **Accent Color:** Salem `#0F8044`
- **Fonts:** Playfair Display, Montserrat, Open Sans

## Links

- **Privacy Policy:** https://winebro.web.app/privacy-policy.html
- **Deletion Policy:** https://winebro.web.app/deletion-policy.html
- **Firebase Console:** https://console.firebase.google.com/project/winebro
