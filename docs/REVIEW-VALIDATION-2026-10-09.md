# Validation of "WineBro deep product, Firestore and UX review" (9 Oct 2026)

Checked claim by claim against the code on branch `feat/config-to-firestore` and the live Firestore
project `winebro` on 9 Oct 2026. Verdict per item: **Confirmed**, **Partly**, **Wrong** or **Out of date**.

## 1. P0 findings

| ID | Claim | Verdict | Evidence |
|---|---|---|---|
| P0-02 | Any signed-in user can write `pairing_aggregates`; client updates them | **Confirmed** | `firestore.rules` allows write with only `yes/maybe/no >= 0`; `pairing_feedback_sheet.dart` runs the increment transaction on the client. |
| P0-03 | Gamification state is client-written; CF-02 corrects after the fact; first write is not capped | **Confirmed** | rules allow owner write to `gamification/*`; `cf02-xp-validation.ts:130` caps only when `oldData` exists. |
| P0-04 | Account deletion incomplete; Settings says "coming soon" | **Confirmed** | `cf04` deletes only `journal`, `gamification`, `dailyPick`; no Storage, `phone_index`, `pairing_feedback`, `wishlist`, `friends`, `fcm_token`, quiz docs. `settingsDeleteComingSoon` string is live. |
| P0-05 | `phone_index` readable by every user, writable with own uid; SHA-256 of phone is enumerable | **Confirmed** | rules lines 117-120. |
| P0-06 | Streak cron runs 18:35 IST, not 00:05 IST | **Confirmed** | `schedule: "35 18 * * *"` + `timeZone: "Asia/Kolkata"`; Cloud Scheduler reads the cron in the given zone ([Firebase docs](https://firebase.google.com/docs/functions/schedule-functions)). |
| P0-07 | App writes `users/{uid}/fcm_token/primary`; CF-02 reads `users/{uid}.fcmToken` | **Confirmed** | `notification_handler.dart:158`, `cf02:195`. Badge pushes never send. |
| P0-08 | Seed catalogue silently replaces remote data when empty/error | **Confirmed** | `pairing_providers.dart:64,70`. |
| P0-09 | Only 55 drinks / 66 dishes; 0 verified; no images; 8 of 13 categories | **Out of date / Partly** | Live Firestore: **111 drinks** (11 of 13 categories; no gin, no tequila), 66 dishes, **0 verified** (true), **37 drinks + 50 dishes have open-licence photos**, ABV known for 71/111, every drink carries an "Estimated from published facts" label with confidence. Curated pairing edges: 148, median 2 per dish, and **none of the 56 pilot drinks has a curated edge**. The 2,000-item floor is the reviewer's proposal, not a measured requirement. |

## 2. P1 findings

| ID | Verdict | Note |
|---|---|---|
| P1-01 journal rules weak | **Confirmed** | create requires only `productName`, `rating` 1-5, `createdAt`; update unrestricted. |
| P1-02 malformed rows skipped silently; `sortOrder` not required | **Partly** | admin API validates ids/names/scores but not `sortOrder`. |
| P1-03 config world-readable, parse fallback | **Confirmed by design** | fallback per document is deliberate; versions and history exist; no signing. |
| P1-04 initial notification handled before router bound; all topics subscribed | **Confirmed** | `getInitialMessage` → `_onOpened` in `initialize()`; `subscribeAll()` loops every type. |
| P1-05 unbounded scheduled scans | **Plausible, not measured** | 5 users today; becomes real at scale. |
| P1-06 flag written before FCM send | **Confirmed** | `cf09` comment and code: `feedbackRequestedAt` set before `send`. |
| P1-07 no release evidence / App Check | **Confirmed** | no App Check; no CI. |
| P1-08 version metadata | **Out of date** | Settings reads `package_info_plus`; build 12 is current. |
| P1-09 icon only in design-preview | **Wrong** | adaptive vectors + iOS PNGs shipped in build 11 (`android/app/src/main/res/drawable/winebro_app_icon_*.xml`). |

## 3. Other statements

- "`aromatic` has no rule" — **Wrong**: `config/pairingRules.foodFitRules.aromatic` gives +10 when complexity ≥ 5. "`acidic` unused by any dish" — **Confirmed** (0 dishes).
- "Emotion tiles all route to Pair without filtering" — **Confirmed** (`config/home`).
- "Flashlight must work or be removed" — **Not applicable**: there is no flashlight control in the scanner.
- "Voice input stub" — **Out of date** for Pair (speech-to-text search shipped in PR #56); the Journal voice note button still shows "Voice coming in v1.1".
- "Admin app has no authentication" — **Out of date**: Google sign-in with an allow-list went live 9 Oct (`admin_access/allowlist`).
- Market context: IWSR puts Indian wine at ~4.3 million 9-litre cases with 15–20 million new legal-age consumers a year; imports grew ~50% by volume in H1 2025, led by young consumers ([IWSR](https://www.theiwsr.com/insight/how-to-win-in-indias-beverage-alcohol-market/), [Wine Intelligence](https://wine-intelligence.com/blogs/wine-news-insights-wine-intelligence-trends-data-reports/india-s-wine-imports-surge-in-2025-driven-by-young-consumers-and-premium-demand)). The review's "premiumisation and young consumers" hypothesis holds.

## 4. Our analysis (what the review under-weights)

1. **The data-trust loop already has a backbone.** Every drink has provenance (`source`, `provenance`, `estimate.confidence`), open-data links with licences, and a console with versioned rules. What is missing is a *review state* per record (0 verified) and curated pairings for the 56 pilot drinks. That is content work, now unblocked by the console.
2. **Security items are small code, big trust.** P0-02/03/05/06/07 are each under a day of engineering and remove the ways a modified client can poison shared data. They go first.
3. **Honest states beat fallbacks.** Firestore's own offline cache already covers "no network". The seed fallback hides outages; removing it and showing an error/empty state is the right fix (P0-08).
4. **Category adapters are the next engine step, not more rules.** Six wine-shaped axes for whisky and beer is a known limit; the config now allows new food properties and rules without a release, so adding `sweetness`, `bitterness`, `carbonation`, `oak/peat` as drink attributes is a data-model change we should plan, not improvise.
5. **2,000 items is not the gate; city coverage is.** With 111 drinks the scanner will miss most shelves. The practical gate is: the top ~300 SKUs in two launch cities, each with a photo, ABV, category and at least 3 curated pairings, plus "not found — add this bottle".

## 4b. Recheck against the updated review (Home sections, data sources) — 9 Oct, late

The review grew by four sections (Home assessment, Home 2.0 verification, Home correction, data-source
acquisition). Rechecked against the P0 work in PR #58 and the Home work in progress in the working tree
(`home_screen.dart`, `home_providers.dart`, `product_action_row.dart`, not mine, not committed by me):

| Topic | Interaction with PR #58 | Status |
|---|---|---|
| Home gating of Tonight's Pour / Bro Circle / Bro Tip; "Type a dish"; retail disabled | None of those files are touched by #58. Combined tree compiles: 0 errors; the only warnings are in the Home files (unused `_BroTipCard`, dead code in `product_action_row.dart`) and belong to that work. | No conflict |
| Catalogue no longer falls back to seed (#58 U7) | Home's Tonight's Pour, quick-start chips and Bro Circle read `allProductsProvider` / `allDishesProvider`; during a load error they now get an empty list instead of seed rows. Pair shows the `CatalogStateBanner`; **Home does not yet** (left for the Home owner to add one line: `const SliverToBoxAdapter(child: CatalogStateBanner())`). | Follow-up for Home |
| "Continue Story 78% is hard-coded" | Not changed by #58. | Open (Home) |
| "Bounded by 55 product records" (Home 2.0 verification) | Out of date: 111 live. | — |
| Data sources: Open Food Facts images are CC BY-SA and "do not store a third-party page image by hotlink" | The app hotlinks 27 Open Food Facts and 10 Commons photo URLs with per-photo author/licence credits (Photo credits screen). Commons per-file licences are stored; OFF image reuse should be confirmed against the OFF terms, or replaced by uploads through the console. | Decision needed |
| "Generative-AI output must not be a factual product profile" | All 111 drinks carry `provenance: ai-estimate` taste scores, shown as "Estimated from published facts" with confidence; facts (ABV, producer, style) come from open data. This matches the review's `candidate` status; sommelier review (pilot stage 5) upgrades them to `reviewed`. | Consistent, review pending |
| Live proof of #58 (`functions/scripts/verify-p0.js`, throwaway user) | scan → 55 XP + Eagle Eye; journal+pairing → 170 XP + The Pen + Matchmaker; feedback yes → aggregate 1/0/0; change to no → 0/0/1; user-doc delete → journal, gamification, events, feedback rows gone. | Passed on the deployed functions |

Deployed 9 Oct: rules; `gamificationEvents`, `pairingFeedbackAggregate`, `registerPhoneIndex`, `lookupContacts`, `deleteAccount`, `userDocCleanup` (asia-south1); old `gamificationValidator` and us-central1 deletion functions removed. Build 12 on testers' phones still writes `gamification/*`, `pairing_aggregates` and `phone_index` directly, which the new rules deny — build 13 from PR #58 should follow.

## 5. Upgrade programme (code) — done in PR after #57

| # | Item | Change |
|---|---|---|
| U1 | P0-06 | Streak cron `5 0 * * *` Asia/Kolkata. |
| U2 | P0-07 | All functions read `users/{uid}/fcm_token/*`; invalid tokens deleted after send failure. |
| U3 | P0-02 | `pairing_aggregates` server-only; `pairing_feedback` create-only, owner-bound, one per entry; CF trigger updates the aggregate in a transaction. |
| U4 | P0-03 | `gamification/*` server-only. App writes immutable `users/{uid}/events/{id}` (scan, journalEntry, pairing). CF trigger computes XP, counters, streak, level and badges from `config/gamification` + `config/badges`. |
| U5 | P0-04 | `deleteAccount` removes every user subcollection, Storage `users/{uid}/`, `phone_index` rows, `pairing_feedback` rows, then the Auth user. Settings "Delete account" works with a confirmation. |
| U6 | P0-05 | `phone_index` closed to clients. Callables: `registerPhoneIndex` (server hashes the verified phone with a secret pepper) and `lookupContacts` (bounded, rate-limited). |
| U7 | P0-08 | No silent seed fallback: loading / empty / error states in Pair and Home. |
| U8 | P1-01 | Journal rules: typed fields, bounded text, immutable id/userId, rating 1-5. |
| U9 | P1-04/06 | Cold-start notification queued until router is ready; "sent" flags written after a successful send. |
| — | App Check | Not enabled: needs Play Integrity/App Attest setup and a tester rollout plan; listed for the next release. |
