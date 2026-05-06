# App Store Connect — Paste-Ready Fill-In

> **Purpose:** Every field in App Store Connect for the WineBro v1.0.0 submission, pre-filled. Walk top-to-bottom in the App Store Connect UI; copy-paste each section. Total: ~10-15 minutes instead of 45.
>
> **Last updated:** 2026-05-06 · WineBro v1.0.0 · Apple ID 6766765481 · Bundle `com.chv.winebro`

---

## 1. App Information

| Field | Value |
|---|---|
| Name | `WineBro` |
| Subtitle (30 char max) | `Indian wine pairing app` |
| Privacy Policy URL | `https://winebro.web.app/privacy-policy.html` |
| Category — Primary | **Food & Drink** |
| Category — Secondary | **Lifestyle** |
| Content Rights — contains, displays or accesses third-party content? | **No** |
| Age Rating | (filled via questionnaire — see §3) |

---

## 2. Pricing and Availability

| Field | Value |
|---|---|
| Price | **Free** (₹0) |
| Availability | **India only** to start. Add other markets after launch. |
| Pre-orders | **No** |
| Distribute on | **App Store** (NOT Custom Apps / B2B) |

---

## 3. Age Rating Questionnaire (alcohol app — be precise here)

App Store Connect → App Information → Age Rating → Edit. Answer in this order:

| Question | Answer |
|---|---|
| Cartoon or Fantasy Violence | **None** |
| Realistic Violence | **None** |
| Prolonged Graphic or Sadistic Realistic Violence | **None** |
| Profanity or Crude Humor | **None** |
| Mature/Suggestive Themes | **None** |
| Horror/Fear Themes | **None** |
| Medical/Treatment Information | **None** |
| **Alcohol, Tobacco, or Drug Use or References** | **Frequent / Intense** |
| Simulated Gambling | **None** |
| Sexual Content or Nudity | **None** |
| Graphic Sexual Content and Nudity | **None** |
| Contests | **None** |
| Unrestricted Web Access | **No** |
| Gambling | **No** |
| **Result Apple computes:** | **17+** |

> **Why "Frequent/Intense" for alcohol:** WineBro recommends, ranks, and journals alcoholic beverages as core function. Don't downplay it — Apple will flag and reject if the questionnaire understates a category that's central to the app.

---

## 4. App Privacy (Data Collection Disclosures)

App Store Connect → App Privacy → Get Started. Three sections to fill:

### 4a. Data Linked to User
*(Identifiable to the specific user account)*

| Data Type | Used For | Why we collect |
|---|---|---|
| **Phone Number** | App Functionality, Authentication | Phone OTP signup (Firebase Auth) |
| **Name** | App Functionality | Display name on Profile/BroCard |
| **Other User Contact Info** *(hashed contact phone numbers)* | App Functionality | SHA-256 hash matching for "Find friends from contacts" — raw phones never leave device |
| **Other Diagnostic Data** *(crash logs)* | App Functionality, Analytics | Firebase Crashlytics |
| **Photos or Videos** | App Functionality | Optional bottle/label photos in BroCard journal |
| **Audio Data** | App Functionality | Optional voice notes in BroCard journal |
| **User Content** *(tasting notes, ratings)* | App Functionality, Product Personalization | Journal entries, pairing feedback |
| **Other User Content** *(BroCards, wishlist, friends list)* | App Functionality, Product Personalization | Core journaling + friend graph |
| **Coarse Location** *(city only, optional via quiz)* | App Functionality, Product Personalization | Regional palate calibration |
| **Product Interaction** *(search queries, taps on Buy)* | App Functionality, Analytics | Improve pairing engine |
| **Other Usage Data** *(streak, XP, badges)* | App Functionality | Gamification state |

### 4b. Data Not Linked to User
*(Anonymous aggregates — no user account binding)*

| Data Type | Used For | Why |
|---|---|---|
| **Product Interaction** *(community signals)* | Analytics | CF-11 nightly rollup of unique-uid counts per product (no per-user link) |
| **Other Usage Data** *(pairing aggregates)* | Analytics | "Did Bro get it right?" Yes/Maybe/No counter rollup |

### 4c. Data Used to Track You
**No data used for tracking.** WineBro does NOT use IDFA, cross-app tracking, or third-party advertising SDKs. (Confirmed: `NSUserTrackingUsageDescription` declares "we don't track" in Info.plist.)

---

## 5. App Review Information

App Store Connect → App Review Information section.

### 5a. Sign-In Information (REQUIRED — Apple needs to log in)
Phone OTP is the only auth method, so a real Apple test phone number won't work for them. Use:

| Field | Value |
|---|---|
| Sign-in required | **Yes** |
| User Name | `+91 9999900001` *(reserved test phone — see Notes for Reviewer)* |
| Password | `654321` *(static OTP for the reserved test phone — wired in Firebase Auth Console)* |

> **You must do this in Firebase Console first:** Firebase → Authentication → Sign-in method → Phone → "Phone numbers for testing" → add `+91 9999900001` with code `654321`. Apple Reviewer will use this exact pair to sign in. If you don't reserve this number, Apple will reject for "unable to sign in."

### 5b. Notes for Reviewer (paste verbatim)

```
Thanks for reviewing WineBro.

WineBro is a wine, spirits, and beer pairing app for Indian users.
The full app is locked behind a phone-OTP sign-in (Firebase Auth).
For your review, please use the reserved test number:

  Phone:  +91 9999900001
  OTP:    654321

This number is configured in our Firebase Auth project as a static
test credential — it will not actually receive an SMS, and the OTP
above is hard-coded to work.

After signing in:
  1. Enter any name on the "What should we call you?" screen
  2. Tick the 21+ age-confirmation checkbox + agree to Privacy/Terms
  3. Take the 7-question palate quiz (any answers are fine)
  4. Land on Home — Tonight's Pour, emotion tiles, Bro Circle

Key flows to verify:
  - Pair tab: search "biryani" → see ranked bottle recommendations
  - Scan FAB: camera-based bottle label scanner (real bottle works
    best; we packaged sample images at the link below if needed)
  - Journal tab: tap the floating "+ button → Quick-log → save
    (15-second journaling) OR tap the upgrade CTA for full BroCard
  - Profile: see streak, XP, badges, Yearly Wrap-up (if 5+ entries)

Notes on category:
  - The app contains alcohol references throughout (this is its
    purpose). Age gate is enforced at signup with an explicit
    21+ checkbox; no content is accessible without confirmation.
  - All content is informational/educational — no purchase or
    sale of alcohol happens inside the app. Affiliate "Buy" links
    open external retailers (Flipkart, BigBasket, Amazon) which
    handle their own age verification.
  - Privacy policy: https://winebro.web.app/privacy-policy.html
  - Terms: https://winebro.web.app/terms.html

If you encounter any issue, please email: [your email]
```

### 5c. Contact Information

| Field | Value |
|---|---|
| First name | *(your first name)* |
| Last name | *(your last name)* |
| Phone | *(your phone)* |
| Email | *(your email — Apple uses for any review correspondence)* |

### 5d. Demo Account in App Notes (Yes/No)
**Yes** (the test phone above counts).

---

## 6. Version 1.0 Information

App Store Connect → 1.0 Prepare for Submission.

### 6a. Promotional Text (170 char — can update without re-review)
```
India's first homegrown wine pairing app. Scan any bottle, ask what pairs with biryani, log what you drank, see what your friends are pouring. 21+ only.
```

### 6b. Description (4000 char limit; this version 1,920 char)
```
WineBro is your pocket sommelier — built for India.

Stop Googling "what wine goes with butter chicken?" and getting answers written for someone in Tuscany. WineBro pairs wines, whiskies, and beers with the food you actually eat — Hyderabadi biryani, Bengali Macher Jhol, Goan Vindaloo, Rajasthani Laal Maas, Chettinad chicken, your dadi's Sunday Kosha Mangsho.

WHY BROS LOVE IT

• 55+ wines, whiskies & beers from Sula, Grover Zampa, Amrut, Paul John, Bira, Old Monk and 7 more iconic Indian brands — plus the imports you actually buy.

• 66+ dishes across 7 regional cuisines — North & South Indian, Bengali, Kashmiri, Hyderabadi, Goan, Rajasthani, Chettinad, Udupi.

• Pairing engine that learns — based on your taste quiz, your tasting journal, and what other Bros loved.

• Scan any bottle — instant tasting notes, pairing suggestions, where to buy.

• BroCard journal — log what you drank in 15 seconds. Or go full sommelier with detailed tasting notes, photos, and voice notes.

• Aroma wheel calibrated for Indian palates — Aam, Jamun, Imli, Kesar, Tandoor smoke. Not just "blackcurrant."

• Bro Circle — see what your friends are pouring this week.

• Streaks, badges, levels — because tasting wine is fun.

• Hindi, Marathi, Gujarati support — coming soon.

FREE TO USE. NO SUBSCRIPTION WALL. WineBro earns when you tap "Buy" — we get a small commission from the retailer at no cost to you.

PRIVACY-FIRST FRIEND DISCOVERY
Your contacts never leave the device. We hash phone numbers locally (SHA-256) before checking which ones are on WineBro. Profile visibility (Public / Friends-only / Private) is in your control.

FOR 21+ ONLY. Drink responsibly. Always.

Built in Bengaluru by people who genuinely believe Indian food deserves a wine pairing app that wasn't written for someone in California.

Privacy policy: https://winebro.web.app/privacy-policy.html
Terms of service: https://winebro.web.app/terms.html
```

### 6c. Keywords (100 char limit, comma-separated, NO spaces)
```
wine,whisky,beer,pairing,sommelier,india,biryani,sula,grover,amrut,bira,oldmonk,journal,bottle,scan
```
*(Counts: 99 char ✓)*

### 6d. Support URL
```
https://winebro.web.app
```

### 6e. Marketing URL (optional, leave blank for v1 or use the same)
```
https://winebro.web.app
```

### 6f. Version Number
```
1.0.0
```

### 6g. Copyright
```
© 2026 Culinary Happiness Ventures Pvt. Ltd.
```

### 6h. What's New in This Version
*(For v1.0 — will only show after a future v1.1 ships)*
```
First public launch. Pair any Indian dish with 55+ bottles, scan labels for instant tasting notes, journal what you drink in 15 seconds.
```

---

## 7. Screenshots

Apple requires the **6.5" iPhone** size at minimum (iPhone 11 Pro Max, 12/13/14 Pro Max — 1242 × 2688 px). The 6.7" (15 Pro Max) is also accepted. iPad screenshots are optional.

| Slot | Screen | File location | Caption overlay |
|---|---|---|---|
| 1 | Home — Tonight's Pour | `assets/store/ios/01-home.png` | "Bro picks tonight's bottle." |
| 2 | Pair — dish search | `assets/store/ios/02-pair-search.png` | "What goes with biryani?" |
| 3 | Pair — result card | `assets/store/ios/03-pair-result.png` | "Tamakua Riesling. 91% match." |
| 4 | Scanner — match | `assets/store/ios/04-scanner.png` | "Snap it. Bro knows it." |
| 5 | BroCard — quick log | `assets/store/ios/05-quicklog.png` | "15 seconds. Done." |
| 6 | Aroma Wheel | `assets/store/ios/06-aroma.png` | "Aam. Jamun. Imli. Tandoor." |
| 7 | Profile — Wrap-up | `assets/store/ios/07-wrapup.png` | "Your year in tastings." |
| 8 | Bro Circle | `assets/store/ios/08-circle.png` | "3 friends loved this week." |

If those exact files don't exist yet, the existing iOS screenshots from PR #11 are at `assets/screenshots/ios/`. Use them as-is; Apple just needs *valid* screenshots for v1, not perfect ones — you can update post-launch without re-review.

---

## 8. App Store Connect Build (after Codemagic uploads)

When Codemagic finishes the first iOS build and pushes it to TestFlight:

1. App Store Connect → 1.0 Prepare for Submission → **Build** → "+" → pick the build that just landed
2. Fill the export compliance question: **No** (we don't use any non-exempt encryption — `ITSAppUsesNonExemptEncryption = false` in Info.plist already declares this)
3. After build is attached, the **Submit for Review** button at top-right enables

---

## 9. Submit for Review checklist (final pass before clicking)

- [ ] Sections 1, 2, 3, 4 all complete (green ticks in left rail)
- [ ] Promotional text + Description + Keywords + Support URL filled (Section 6)
- [ ] 8 phone screenshots uploaded
- [ ] Build selected from TestFlight
- [ ] App Review Information populated with `+91 9999900001` / `654321`
- [ ] **Reserved test phone added in Firebase Console** (Auth → Sign-in method → Phone → testing numbers)
- [ ] Notes for Reviewer pasted from §5b
- [ ] Contact Information filled
- [ ] Pricing = Free, Availability = India

Click **Submit for Review**. Apple reviews typically resolve in 24-48h for new apps; alcohol category sometimes takes 72h. Status flow:

```
Waiting for Review → In Review → Pending Developer Release  (success)
                                  Rejected                    (fix → resubmit)
```

When **Pending Developer Release** appears, you click **Release this version** in App Store Connect — live on the store within ~30 min.

---

## 10. If Apple rejects (likely reasons + my prepared responses)

### R1 — "Unable to sign in (incorrect OTP)"
*Cause:* Reserved test phone `+91 9999900001` not added in Firebase Auth Console.
*Fix:* You add it. Reply to Apple Reviewer in Resolution Center: "Apologies — test phone has been added. Please retry with +91 9999900001 / 654321."

### R2 — "Glamorizes or encourages alcohol consumption"
*Cause:* Some screenshot caption or tagline crossed the line.
*Fix:* I edit copy in `docs/MARKETING-DECK.md` § 2 + screenshot captions, push a new build, resubmit. Acceptable language: "pair", "discover", "explore", "match". Avoid: "drink more", "party", "shots", anything implying excess.

### R3 — "Missing age gate"
*Cause:* Apple wants the 21+ check before any alcohol content is visible.
*Fix:* Already shipped (PR #33). Reply: "Age gate is on the NameScreen which fires before any alcohol content is rendered. Confirm by signing in fresh, you'll see the explicit 21+ checkbox before the onboarding intro."

### R4 — "Privacy policy doesn't match disclosed data collection"
*Cause:* App Privacy questionnaire (§4) doesn't match what `https://winebro.web.app/privacy-policy.html` says.
*Fix:* I sync the privacy policy text to match §4 exactly, redeploy hosting, reply to Apple.

### R5 — "Push notification authorization prompt timing"
*Cause:* Apple wants the prompt at moment-of-need, not at app launch.
*Fix:* Already shipped — `NotificationHandler.registerForUser` fires only on first transition to `Authenticated` state, not at app launch. Cite this in Resolution Center if flagged.

---

## 11. Post-launch — what I track for you

After release, I'll watch for:
- Day 1-3 install velocity (App Store Connect → Analytics)
- First-day crash rate (Firebase Crashlytics — should stay <1%)
- First D6 pairing-feedback responses landing (CF-09 fires 24h after first journal entry — confirms the data flywheel is spinning)
- Any "Sign in failed" reports from real users (Firebase Auth → Logs)

Any one of those triggers a hotfix sprint if needed.
