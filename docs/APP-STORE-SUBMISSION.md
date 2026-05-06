# WineBro — iOS App Store Submission Pack

> **TL;DR:** This repo is fully App Store-compliant on the code side. The remaining work is six sequential clicks across two browser tabs (Apple + Codemagic) plus holding your iPhone for 5 minutes. Total time: ~45 minutes. The detailed runbook is **§1**. Everything below it is reference material.

---

## §1. The Only Things Left To Do (Runbook)

### Step 1 — Apple Developer Program enrollment ✅ DONE (2026-05-06)
- **Team ID:** `YWB9J8THH3`
- **Program:** Apple Developer Program
- **Enrolled as:** Individual
- Skip to Step 2.

### Step 2 — Create the App Store Connect API key
- Open **https://appstoreconnect.apple.com/access/integrations/api**
- Click **+** → Name: `Codemagic-WineBro` → Access: **Admin** → Generate.
- Click **Download API Key** — you get one chance. Save the `.p8` file as `D:\AIMinds\WineBro\.signing\AuthKey.p8` (the `.signing/` folder is gitignored).
- From the same page, copy:
  - **Issuer ID** (UUID, top of page)
  - **Key ID** (10-char, in the row of the key you just made)

### Step 3 — Create the app record in App Store Connect
- Open **https://appstoreconnect.apple.com/apps**
- Click **+** → New App → fill:
  - Platform: iOS
  - Name: **WineBro**
  - Primary language: English (India)
  - Bundle ID: select `com.chv.winebro` (Apple may require you to register it first at https://developer.apple.com/account/resources/identifiers/list — App ID, Description "WineBro", Bundle ID Explicit `com.chv.winebro`, Capabilities: Push Notifications, Sign in with Apple if used)
  - SKU: `winebro-ios-001`
  - User Access: Full Access
- Click Create. **Copy the numeric Apple ID** that appears in the URL (`/app/<digits>`) — this is your `APP_STORE_APPLE_ID`.

### Step 4 — Sign up for Codemagic and connect everything
- Open **https://codemagic.io/signup** → "Sign up with GitHub" → authorize.
- Top-right avatar → **Teams → Personal Team → Integrations**:
  - **Apple Developer Portal** → Connect → name `WineBroApple` → Issuer ID + Key ID + upload the `.p8`. Save.
  - **App Store Connect** → Connect → name `WineBroAppStoreConnect` → Issuer ID + Key ID + upload the same `.p8`. Save.
  - **Note:** the workflow file (`codemagic.yaml`) references the App Store Connect integration by the exact name `WineBroAppStoreConnect`. If you choose a different name, update line 6 of `codemagic.yaml`.
- Dashboard → **Add application** → GitHub → pick `dushyantb11-rgb/winebro` → "I have a codemagic.yaml file in my repository" → Finish.

### Step 5 — Wire the App Store Apple ID into the workflow
- One value still needs filling. Edit `codemagic.yaml` line `APP_STORE_APPLE_ID: "REPLACE_WITH_NUMERIC_APP_ID"` and paste the numeric ID from Step 3.
- Commit and push to `main`. Codemagic auto-detects the push and starts the build.

### Step 6 — Install on iPhone 17 Pro and capture screenshots
- Wait ~15 min for the Codemagic build to finish and upload to TestFlight.
- App Store Connect → TestFlight → Internal Testing → create group **"WineBro Internal"** (the workflow expects this exact name) → add your Apple ID as a tester.
- Install **TestFlight** app on your iPhone 17 Pro from the App Store → sign in with the same Apple ID → WineBro appears → Install.
- iPhone settings: light mode + airplane mode (clean status bar).
- Capture the 6 screens listed in §5 (Side button + Volume Up).
- AirDrop the PNGs to Windows → drop in `D:\AIMinds\WineBro\app-store-assets\screenshots\`.
- Upload to App Store Connect → App Store → 6.3" iPhone screenshots.
- Fill the listing fields from §3 (copy/paste).
- Submit for Review.

That's it. Six steps.

---

## §2. What Already Ships in the Repo

| Layer | Status |
|-------|--------|
| iOS Privacy Manifest (`PrivacyInfo.xcprivacy`) | ✅ Bundled |
| Info.plist permission strings (camera, photos, mic, tracking) | ✅ Set |
| `ITSAppUsesNonExemptEncryption=false` | ✅ Set (no per-build prompt) |
| Codemagic workflow (`codemagic.yaml`) — automatic signing, auto build-number, TestFlight upload | ✅ Committed |
| GitHub Actions workflow (`.github/workflows/ios-release.yml`) — backup path | ✅ Available |
| Static analysis + unit tests as quality gate | ✅ On every PR + release |
| `.signing/` and all certificate file types in `.gitignore` | ✅ |
| Submission pack (this doc) | ✅ Versioned in repo |

The Codemagic path uses Codemagic's **automatic code signing** — they generate the distribution certificate and provisioning profile on the fly via your App Store Connect API key, then bundle them into the build, then push the IPA to TestFlight. You never hold a `.p12` in your hand.

---

## §3. App Store Connect Listing Copy

### App Name (max 30 chars)
```
WineBro
```

### Subtitle (max 30 chars)
```
Wine, spirits & food pairing
```

### Promotional Text (max 170 chars)
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

### Keywords (max 100 chars, comma-separated, no spaces)
```
wine,whisky,pairing,sommelier,tasting,journal,scanner,aroma,gin,rum,cocktail,palate,spirits,food
```

### Support URL
```
https://winebro.web.app/support
```

### Marketing URL
```
https://winebro.web.app
```

### Privacy Policy URL
```
https://winebro.web.app/privacy-policy.html
```

### Copyright
```
© 2026 CHV Beverages Pvt. Ltd.
```

### What's New in This Version
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

## §4. App Privacy Questionnaire

Mirror this in App Store Connect → App Privacy. Matches the on-device `PrivacyInfo.xcprivacy`.

| Data Type | Collected | Linked | Tracking | Purpose |
|-----------|-----------|--------|----------|---------|
| Email Address | Yes | Yes | No | App Functionality |
| Name | Yes | Yes | No | App Functionality |
| User ID | Yes | Yes | No | App Functionality |
| Photos or Videos | Yes | Yes | No | App Functionality |
| Product Interaction | Yes | Yes | No | Analytics + App Functionality |
| Other Usage Data | Yes | Yes | No | Analytics |
| Crash Data | Yes | No | No | App Functionality |
| Performance Data | Yes | No | No | Analytics |

**Tracking:** No. WineBro does not use IDFA, does not share data with third-party data brokers or ad networks.

---

## §5. Screenshot Spec & Capture Plan

iPhone 17 Pro native is **1206 × 2622** (6.3" class). App Store Connect accepts this directly and auto-derives the 6.9" gallery view.

| Device class | Resolution (px, portrait) | Source |
|--------------|---------------------------|--------|
| 6.3" iPhone (17 Pro) | 1206 × 2622 | Captured on your device |
| 13" iPad (optional) | 2064 × 2752 | Generate from a simulator only if you want iPad in the listing |

### Six screens to capture (in order)

1. **Hero** — first launch / logo + tagline
2. **Palate Quiz** — first quiz card
3. **Label Scanner** — viewfinder framing a bottle
4. **Pairing result** — "What goes with butter chicken?"
5. **BroCard** — finished tasting journal entry
6. **Aroma Wheel + palate radar** — the geeky reward screen

---

## §6. Age Rating Answers

In App Store Connect → Age Rating, answer **"Frequent/Intense"** for *Alcohol, Tobacco, or Drug Use or References*. Everything else → **None**. Result: **17+**.

---

## §7. Export Compliance

Already declared in `Info.plist` via `ITSAppUsesNonExemptEncryption=false`. WineBro uses only standard HTTPS/TLS. No annual self-classification report required.

---

## §8. Reviewer Notes (paste into App Review Information at submission)

```
WineBro is a wine and spirits pairing companion for adults of legal drinking age (18+ in India). Camera permission is used solely for on-device label text recognition (Google ML Kit) — no images are uploaded or recorded. Photo library permission is used to attach images to private tasting journal entries stored in the user's account.

Demo account for skipping Google Sign-In:
  Email:    review@winebro.app
  Password: WineReview2026!

The app does not encourage harmful consumption and includes an explicit responsible-drinking notice.
```

(Update demo creds before submission.)

---

## §9. Pre-empted Rejection Reasons

| Risk | How this build mitigates it |
|------|------------------------------|
| Missing PrivacyInfo.xcprivacy | Shipped at `ios/Runner/PrivacyInfo.xcprivacy`, wired into Xcode |
| Missing camera/photo permission strings | Feature-specific copy in `Info.plist` |
| Per-build encryption export prompt | `ITSAppUsesNonExemptEncryption=false` |
| Alcohol content without age gate | App enforces 18+ on first launch; declared 17+ to Apple |
| Vague privacy policy | Hosted, DPDPA + GDPR-compliant |
| Crash on review | `flutter analyze` + `flutter test` gate every build via Codemagic |
| Sign-in wall with no demo account | Demo creds in §8 reviewer notes |
| Build-number conflict on TestFlight | Codemagic auto-increments via App Store Connect API |
