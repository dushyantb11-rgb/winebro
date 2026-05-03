# WineBro — iOS App Store Submission Pack

Version targeted: **0.1.0 (build 1)**
Bundle ID: **com.chv.winebro**
Category (primary): **Food & Drink**
Category (secondary): **Lifestyle**
Age rating: **17+** (Frequent/Intense Alcohol, Tobacco, or Drug Use or References)
Pricing: **Free**
Availability: **India** at launch (expand later)

---

## 1. App Store Connect — Listing Copy

### App Name (max 30 chars)
```
WineBro
```

### Subtitle (max 30 chars)
```
Wine, spirits & food pairing
```

### Promotional Text (max 170 chars, can change without resubmission)
```
Scan any label, get instant pairing ideas, and build a tasting journal with your elder bro in wine. New aromas, badges and BroCards every week.
```

### Description (max 4000 chars)
```
WineBro is your elder brother in the world of wine, spirits and food pairing.

Whether you are picking your first bottle or building a serious palate, WineBro helps you understand what you are drinking, what to pair it with, and how to remember every sip.

WHAT YOU CAN DO

• Take the Palate Quiz — a 6-axis taste profile that learns whether you lean sweet or dry, fruity or smoky, light or full-bodied.
• Scan any label — point your camera at a wine or spirit bottle and WineBro reads the label, identifies the style, and suggests what to eat with it.
• Smart Pairing Engine — start from a dish, an occasion, or a mood, and get curated wine, whisky, gin and rum suggestions that actually match.
• Tasting Journal & BroCards — log every bottle you try as a beautiful BroCard with notes, photo, score and aromas. Look back and watch your palate evolve.
• Aroma Wheel — explore the language of taste with an interactive wheel covering fruit, floral, oak, spice, earth and more.
• Levels, XP and Badges — every tasting earns you XP. Climb from Curious Sipper to Cellar Master.
• Multi-language — available in English, Hindi, Marathi and Gujarati.

WHO IT IS FOR

• Curious beginners who want to stop guessing at the wine shop
• Hosts who want to pair the right drink with the right meal
• Enthusiasts who want a private journal of every bottle they have tried
• Anyone who wants to build a real, personal palate over time

PRIVACY FIRST

WineBro does not sell your data, does not track you across apps, and does not run third-party advertising. Your tasting journal is yours. You can export or delete everything from the app at any time.

DRINK RESPONSIBLY

WineBro is intended for adults of legal drinking age in their country (18+ in India). We do not encourage excessive or harmful consumption. Please drink responsibly.

QUESTIONS

Email us at hello@winebro.app or visit https://winebro.web.app
```

### Keywords (max 100 chars, comma-separated, no spaces after commas)
```
wine,whisky,pairing,sommelier,tasting,journal,scanner,aroma,gin,rum,cocktail,palate,spirits,food
```

### Support URL
```
https://winebro.web.app/support
```

### Marketing URL (optional)
```
https://winebro.web.app
```

### Privacy Policy URL (required)
```
https://winebro.web.app/privacy-policy.html
```

### Copyright
```
© 2026 CHV Beverages Pvt. Ltd.
```

### What's New in This Version (release notes, max 4000 chars)
```
First public release of WineBro.
• Palate Quiz with 6-axis taste profile
• Label Scanner powered by on-device ML
• Smart Pairing Engine for food, drink and occasion
• Tasting Journal with BroCards
• Aroma Wheel explorer
• XP, levels and badges
• English, Hindi, Marathi and Gujarati
```

---

## 2. App Privacy (Data Collection Questionnaire)

Answer each section in App Store Connect → App Privacy. Mirrors the on-device `PrivacyInfo.xcprivacy` we ship.

| Data Type | Collected? | Linked to user? | Used for tracking? | Purpose |
|-----------|-----------|----------------|--------------------|---------|
| Email Address | Yes | Yes | No | App Functionality (account) |
| Name | Yes | Yes | No | App Functionality (profile) |
| User ID | Yes | Yes | No | App Functionality (Firebase Auth UID) |
| Photos or Videos | Yes | Yes | No | App Functionality (label scans, journal) |
| Product Interaction | Yes | Yes | No | Analytics + App Functionality |
| Other Usage Data | Yes | Yes | No | Analytics |
| Crash Data | Yes | No | No | App Functionality (Crashlytics) |
| Performance Data | Yes | No | No | Analytics |

**Tracking:** No. WineBro does **not** use IDFA and does **not** share data with third-party data brokers or ad networks.

---

## 3. Age Rating Questionnaire — Apple

Answer "Frequent/Intense" for **Alcohol, Tobacco, or Drug Use or References**.
Answer "None" for everything else (violence, sexual content, gambling, horror, profanity, mature themes other than alcohol).
Result: **17+**.

---

## 4. Export Compliance

`ITSAppUsesNonExemptEncryption` is set to `false` in `Info.plist`. WineBro uses only standard HTTPS (TLS) provided by iOS — no custom or proprietary encryption — so it qualifies for the export-compliance exemption. No annual self-classification report is required.

---

## 5. Required Screenshots

Apple requires screenshots for at least **6.9-inch iPhone** (iPhone 16 Pro Max — 1320 × 2868). 6.5-inch (iPhone 11 Pro Max class — 1242 × 2688) is recommended for older device coverage. iPad screenshots are required only if the binary supports iPad — WineBro does (`TARGETED_DEVICE_FAMILY = "1,2"`), so include 13-inch iPad screenshots too.

| Device class | Resolution (px, portrait) | Min count | Recommended |
|--------------|---------------------------|-----------|-------------|
| 6.9" iPhone (16 Pro Max) | 1320 × 2868 | 3 | 6 (max 10) |
| 6.5" iPhone (11 Pro Max) | 1242 × 2688 | 3 | 6 (auto-derived if absent) |
| 13" iPad Pro (M4) | 2064 × 2752 | 3 | 6 |

### Suggested screen list (in order — tells the app's story)

1. **Hero** — Logo + tagline: *"Your elder brother in wine."*
2. **Palate Quiz** — first quiz card with the 6-axis taste profile preview.
3. **Label Scanner** — camera viewfinder framing a Pinot Noir bottle.
4. **Pairing result** — "What goes with butter chicken?" with three matched bottles.
5. **BroCard** — a finished tasting journal card.
6. **Aroma Wheel + profile radar** — the geeky reward screen.

Use the in-device screenshot tool (Cmd+S in simulator). Generate from a 6.9" iPhone simulator first — Apple auto-down-fills smaller iPhone classes.

---

## 6. App Icon

App Store listing icon must be **1024 × 1024**, RGB, no transparency, no rounded corners. Already present at `app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png` (generated by `flutter_launcher_icons`).

---

## 7. TestFlight Pre-Submission Checklist

Run this list before clicking "Submit for Review."

**Build pipeline**
- [ ] All required GitHub Actions secrets set:
  - `IOS_P12_BASE64` (Apple Distribution certificate, base64-encoded `.p12`)
  - `IOS_P12_PASSWORD`
  - `KEYCHAIN_PASSWORD` (any random string)
  - `IOS_PROVISIONING_PROFILE_BASE64` (base64-encoded **App Store** distribution profile named `WineBro App Store` matching `com.chv.winebro`)
  - `APPLE_TEAM_ID` (10-char team ID)
  - `ASC_KEY_ID` (App Store Connect API key ID)
  - `ASC_ISSUER_ID` (App Store Connect API issuer ID)
  - `ASC_KEY_BASE64` (base64-encoded `.p8` API key)
- [ ] Bump `version:` in `pubspec.yaml` if marketing version changes (e.g., `0.1.0+1` → `0.1.1+2`).
- [ ] Run workflow: GitHub Actions → "iOS App Store Release" → "Run workflow" with `build_name` and `build_number`.
- [ ] `build_number` must be strictly higher than any previously uploaded build for the same `build_name`.

**App Store Connect setup (one-time)**
- [ ] Create the app record in App Store Connect with bundle ID `com.chv.winebro`.
- [ ] Set primary category Food & Drink, secondary Lifestyle.
- [ ] Fill all listing fields from §1 above.
- [ ] Complete App Privacy questionnaire from §2.
- [ ] Complete Age Rating from §3 → confirm 17+.
- [ ] Set Export Compliance per §4 (or rely on `ITSAppUsesNonExemptEncryption=false` we ship in Info.plist).
- [ ] Upload 1024×1024 icon.
- [ ] Upload screenshots from §5.
- [ ] Add Privacy Policy URL.
- [ ] Add Support URL.

**OAuth wiring (if Google Sign-In is on)**
- [ ] Replace `REVERSED_CLIENT_ID_REPLACE_ME` in `app/ios/Runner/Info.plist` with the actual `REVERSED_CLIENT_ID` from `GoogleService-Info.plist`. (If Google Sign-In is disabled, delete the entire `CFBundleURLTypes` array we added.)

**TestFlight**
- [ ] After upload, wait ~15 min for processing.
- [ ] Add internal testers (your Apple ID + team).
- [ ] Smoke test: install on real device → run quiz → scan a label → log a tasting → check journal persists across reboot.
- [ ] Verify all permission prompts (camera, photos) show the strings from `Info.plist` and *not* the generic Apple default.
- [ ] Confirm Crashlytics receives a test crash event.

**Submit for Review**
- [ ] Provide a demo account (email + password) in App Review Information if any feature requires sign-in.
- [ ] Provide reviewer notes: "Use the demo account to skip Google Sign-In. Camera permission is for label scanning only — no audio or video is recorded. Photos permission is for journal attachments. App targets users 18+ in India."
- [ ] Choose "Manual release" so you control the publish moment after approval.
- [ ] Hit Submit.

**Expected timeline:** TestFlight processing ~15 min → first beta within an hour → App Review queue ~24–72 h → release on your "Manual release" trigger.

---

## 8. Common Rejection Reasons to Pre-empt

| Risk | Mitigation already in this build |
|------|----------------------------------|
| Missing PrivacyInfo.xcprivacy | Shipped at `ios/Runner/PrivacyInfo.xcprivacy`, wired into Xcode resources |
| Missing camera/photo permission strings | Added with feature-specific copy in `Info.plist` |
| Encryption export-compliance prompt on every build | `ITSAppUsesNonExemptEncryption = false` set in `Info.plist` |
| Alcohol content without age gate | App enforces 18+ on first launch; declared 17+ to Apple |
| Vague privacy policy | Hosted at `https://winebro.web.app/privacy-policy.html`, DPDPA + GDPR compliant |
| Crash on review | `flutter analyze` + `flutter test` now gate every release build |
| Sign-in wall with no demo account | Provide demo creds in App Review Information |
