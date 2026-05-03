# WineBro — Google Play Store Submission Pack

> **TL;DR:** Designed Play Store assets are committed at `app/store-assets/play-store/`. Listing copy, Data Safety mapping, and content rating answers are below. Remaining work is enrollment in the Play Console ($25 one-time), uploading the existing release-signed bundle, and pasting the listing copy from this file. Total time after enrollment: ~20 minutes.

---

## §1. Runbook

### Step 1 — Google Play Console enrollment ($25 one-time)
- Open **https://play.google.com/console/signup**.
- Sign in with the Google account that should own the WineBro listing.
- Pay the $25 one-time developer fee.
- Pick **Organization** account (since the app is under CHV Beverages Pvt. Ltd.) — requires a D-U-N-S number or business verification documents.
- If individual is faster, pick **Personal** — can be migrated to Organization later via Play Console support.
- Activation: usually within minutes for personal, 1–3 days for organization.

### Step 2 — Create the app record
- Play Console → **Create app**:
  - App name: **WineBro**
  - Default language: **English (India)**
  - App or game: **App**
  - Free or paid: **Free**
  - Declarations: tick both (Developer Program Policies + US export laws)
- Click Create.

### Step 3 — Build a signed Android App Bundle
The release keystore already lives at `app/android/app/winebro-release.jks`. The build expects `app/android/key.properties` (gitignored) with:
```properties
storePassword=<your keystore password>
keyPassword=<your key password>
keyAlias=<your key alias>
storeFile=winebro-release.jks
```

Build the AAB:
```powershell
cd D:\AIMinds\WineBro\app
flutter clean
flutter pub get
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Step 4 — Upload the bundle to Internal Testing
- Play Console → WineBro → **Testing → Internal testing → Create new release**.
- Upload `app-release.aab`.
- Release name: `0.1.0 (1)`.
- Release notes: paste from §3 below.
- Save → Review release → Roll out.
- On the same page, add testers (Google emails). Tap the share link, install on your Android device, smoke test.

### Step 5 — Fill the Store Listing
Play Console → WineBro → **Grow → Store presence → Main store listing**. Paste fields from §3 below.
Upload from `app/store-assets/play-store/`:
- App icon: `app/assets/icon/app_icon.png` (512×512)
- Feature graphic: `feature-graphic.png` (1024×500)
- Phone screenshots: all six `screenshot-0*.png` (1080×1920)

### Step 6 — Complete the Compliance Forms
Three forms gate production rollout:
- **App content** → Privacy policy URL, ads (No), app access (no special access), content rating questionnaire (§5), target audience 18+, data safety form (§4), government apps (No), financial features (No), health (No), news (No), Covid-19 (No).
- **Pricing & distribution** → Free, all countries (or India-only first), confirm not directed at children.
- **Production release** → After Internal Testing pass, promote the same release track to Production. First production review: 3–7 days.

---

## §2. What Already Ships in the Repo

| Layer | Status |
|-------|--------|
| Release keystore (`android/app/winebro-release.jks`) | ✅ Committed |
| Release signing config (`android/app/build.gradle.kts`) | ✅ Reads `key.properties` |
| `applicationId` `com.chv.winebro` (matches iOS) | ✅ |
| `minSdk 23`, JDK 17, target/compile from Flutter | ✅ |
| App icons via `flutter_launcher_icons` | ✅ |
| Designed Play Store screenshots (6 × 1080×1920) | ✅ `app/store-assets/play-store/screenshot-0*-*.png` |
| Designed feature graphic (1024×500) | ✅ `app/store-assets/play-store/feature-graphic.png` |
| Generator script (regenerate any time) | ✅ `scripts/generate-play-store-assets.js` |
| Submission pack (this doc) | ✅ |

---

## §3. Play Store Listing Copy

### App name (max 30 chars)
```
WineBro
```

### Short description (max 80 chars)
```
Wine, spirits & food pairing. Scan labels, build your palate, journal every sip.
```

### Full description (max 4000 chars)
```
WineBro is your elder brother in the world of wine, spirits and food pairing.

Whether you are picking your first bottle or building a serious palate, WineBro helps you understand what you are drinking, what to pair it with, and how to remember every sip.

WHAT YOU CAN DO

★ Take the Palate Quiz — a 6-axis taste profile that learns whether you lean sweet or dry, fruity or smoky, light or full-bodied.
★ Scan any label — point your camera at a wine or spirit bottle and WineBro reads the label, identifies the style, and suggests what to eat with it.
★ Smart Pairing Engine — start from a dish, an occasion, or a mood, and get curated wine, whisky, gin and rum suggestions that actually match.
★ Tasting Journal & BroCards — log every bottle you try as a beautiful BroCard with notes, photo, score and aromas. Look back and watch your palate evolve.
★ Aroma Wheel — explore the language of taste with an interactive wheel covering fruit, floral, oak, spice, earth and more.
★ Levels, XP and Badges — every tasting earns you XP. Climb from Curious Sipper to Cellar Master.
★ Multi-language — English, Hindi, Marathi and Gujarati.

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

### Release notes for 0.1.0 (max 500 chars)
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

### App category
- **Category:** Food & Drink
- **Tags (up to 5):** Wine, Drinks, Cooking, Lifestyle, Pairing

### Contact details
- **Email:** hello@winebro.app
- **Phone:** (optional, omit unless support team is staffed)
- **Website:** https://winebro.web.app
- **Privacy Policy URL:** https://winebro.web.app/privacy-policy.html

---

## §4. Data Safety Form (App content → Data safety)

Mirror this in the form. Matches the on-device data we collect.

### Data collection summary
- **Does your app collect or share any of the required user data types?** → **Yes**
- **Is all of the user data collected by your app encrypted in transit?** → **Yes** (HTTPS/TLS)
- **Do you provide a way for users to request that their data is deleted?** → **Yes** (in-app delete account)

### Data types collected

| Type | Collected | Shared | Optional? | Purpose |
|------|-----------|--------|-----------|---------|
| Personal info → Name | Yes | No | Required | Account |
| Personal info → Email | Yes | No | Required | Account |
| Personal info → User ID | Yes | No | Required | Account |
| Photos and videos → Photos | Yes | No | Optional | Tasting journal attachments |
| App activity → App interactions | Yes | No | Optional | Analytics, app functionality |
| App activity → Other user-generated content | Yes | No | Required | Tasting journal entries |
| App info → Crash logs | Yes | No | Optional | Crashlytics |
| App info → Diagnostics | Yes | No | Optional | Performance monitoring |

**No location, no contacts, no SMS, no calendar, no microphone, no health data, no financial data, no precise device IDs, no advertising ID.**

---

## §5. Content Rating Questionnaire (IARC)

Answer through Play Console → App content → Content ratings. Expect **17+ / Mature**.

| Question category | Answer |
|-------------------|--------|
| Violence | None |
| Sexual content | None |
| Profanity | None |
| Controlled substance reference (alcohol/tobacco/drugs) | **Yes — frequent** (the app is about wine and spirits) |
| Gambling | None |
| User-generated content | Yes — tasting notes (private to user account; no social sharing in v0.1.0) |
| Social interaction | None in v0.1.0 |
| Personal info shared in-app | No (data stays in user account) |
| Location sharing | None |
| Digital purchases | None in v0.1.0 |

Result: **PEGI 18 / ESRB Mature 17+ / Australia M / IARC equivalent 17+**.

---

## §6. Target Audience and Content

- **Target age groups:** **18 and older** (only).
- **Appeals to children?** No.
- **Ads?** No.

---

## §7. Reviewer Notes (paste into App content → App access)

```
WineBro is a wine and spirits pairing companion for adults of legal drinking age (18+ in India).
Camera permission is used solely for on-device label text recognition (Google ML Kit). No images are uploaded.
Photo permission is used to attach images to private tasting journal entries.

Demo account for testing (Google Sign-In is the only auth path):
  Email:    review@winebro.app
  Password: WineReview2026!

The app does not encourage harmful consumption and includes an explicit responsible-drinking notice on first launch.
```

(Update demo creds before submission.)

---

## §8. Pre-empted Rejection Reasons

| Risk | Mitigation |
|------|------------|
| App promotes excessive alcohol consumption | Includes responsible-drinking notice; positions as pairing/education tool |
| Targeted at minors | Target audience set to 18+; content rating Mature/17+ |
| Missing Data Safety declaration | §4 above mirrors actual data collection; Privacy Policy URL hosted |
| Misleading screenshots | All screenshots are designed mockups of real in-app features (Quiz, Scanner, Pairing, BroCard, Aroma Wheel) — accurate representation per Google's policy |
| Privacy Policy not accessible | Hosted at https://winebro.web.app/privacy-policy.html |
| Sign-in required without demo account | Demo creds in §7 |
| Crash on launch | Internal Testing track must pass before promoting to Production |

---

## §9. Regenerating the Designed Assets

Whenever brand colors, taglines or screen mockups change, run:

```powershell
cd D:\AIMinds\WineBro\scripts
node generate-play-store-assets.js
```

Output overwrites `app/store-assets/play-store/`. The generator is brand-true to CHV's palette (Paprika #93003C, Thunder #252122, Salem #0F8044) and uses Playfair Display + Montserrat (the same fonts shipped in the app).
