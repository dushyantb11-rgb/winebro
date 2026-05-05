# WineBro — Feature Inventory

Every feature in the WineBro Flutter app, grouped by user-facing area.
Each row: one-line description, source paths, current status, known
issues / debt, and what the next work on it would be.

Status legend:
- **Working** — implemented and reachable in production
- **Working (placeholder data)** — UI works, real data not wired
- **Hidden** — code exists, no UI surface yet
- **Deleted** — removed in 2026 redesign
- **Planned** — designed but not coded
- **Stubbed** — UI scaffolded, no behaviour

---

## 1. Authentication

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F1.1 Phone number sign-in** | `lib/features/auth/presentation/screens/login_screen.dart` | Working | Validates Indian phone; auto-submits OTP when valid + age confirmed |
| **F1.2 OTP verification** | `lib/features/auth/presentation/screens/otp_screen.dart` | Working | 6-digit code, resend timer |
| **F1.3 Google Sign-In** | `lib/features/auth/...` (Firebase) | Working (placeholder) | iOS URL scheme wired in `Info.plist` — only needs Firebase Authentication enabled; verify on TestFlight |
| **F1.4 Name / display name capture** | `lib/features/auth/presentation/screens/name_screen.dart` | Working | First-time flow only |
| **F1.5 Age verification gate** | Inline in login | Working | Required tickbox for legal drinking age; per Play Store policy |
| **F1.6 Sign out** | `lib/features/settings/...` | Working | Moved from Profile AppBar in PR #8 |
| **F1.7 Delete account** | `lib/features/settings/...` | Stubbed | Confirm dialog wired; backend wipe endpoint = TODO |
| **F1.8 Auth state machine** | `lib/features/auth/domain/auth_state.dart` | Working | sealed states: Unauth / OtpSent / NeedsProfile / NeedsOnboarding / AuthLoading / AuthError / Authenticated |

---

## 2. Onboarding

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F2.1 Splash + branded loader** | `lib/features/auth/presentation/screens/splash_screen.dart` | Working | 1.8 s scale-in of `logo.png`, paprika gradient bg |
| **F2.2 3-page cinematic intro** | `lib/features/onboarding/presentation/screens/onboarding_intro_screen.dart` | Working | Shipped PR #12. PageView, dot indicator, Skip + "Begin the quiz" CTAs |
| **F2.3 Palate Quiz (6-axis)** | `lib/features/onboarding/presentation/screens/quiz_screen.dart`, `lib/features/onboarding/domain/quiz_engine.dart` | Working | 4 steps (food picks, chaat conditional, drink habit, slider fine-tune) → PalateProfile saved to Firestore |
| **F2.4 Quiz result screen** | Same screen | Working | Shows palate radar + archetype + "Let's Go, Bro!" CTA |
| **F2.5 Quiz visual upgrade (per redesign plan)** | Quiz screen | Planned | Spec written but not coded — light polish only; one-question-per-screen + emotion options with photography. Marked optional in PR #12. |

---

## 3. Home / Discovery

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F3.1 Time-aware greeting** | `home_screen.dart` | Working | "Good morning/afternoon/evening/Up late" + first name + serif italic byline rotating by hour |
| **F3.2 Tonight's Pour hero card** | `home_screen.dart` `_TonightsPourCard` | Working | Pulls from `tonightsPourProvider` — palate-aware + time-aware + daily seed. Falls back to first seed product if no quiz |
| **F3.3 Three emotion tiles (Cooking / Hosting / Just sipping)** | `home_screen.dart` + `shared/widgets/emotion_tile.dart` | Working | All 3 currently route to `/pair`. Should pre-filter Pair by emotion (TODO). |
| **F3.4 Continue Your Story** | `_ContinueStoryCard` + `continueStoryProvider` | Working | Shows last journal entry → suggests adjacent product. Hidden if no entries. |
| **F3.5 Bro Circle social signals** | `_BroCircleCard` + `broCircleProvider` | Working (placeholder data) | 4 ambient signals synthesized locally from product popularity. **Wire to real Firestore counters in v1.1.** |
| **F3.6 Bro Tip of the Day** | `_BroTipCard` | Working (placeholder data) | Single hard-coded tip currently. Should rotate from a tip catalogue (TODO: create `seed_bro_tips.dart`). |
| **F3.7 Pull-to-refresh** | `home_screen.dart` | Working | Re-rolls Tonight's Pour with light haptic |
| **F3.8 Avatar button (top-right)** | `_AvatarButton` | Working | Routes to `/profile`. First-letter initial. |
| **F3.9 Trending products carousel (legacy)** | `trendingProductsProvider` | Hidden | Provider kept but no longer rendered post-redesign. Remove in cleanup. |

---

## 4. Pair (Pairing Engine)

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F4.1 Search-first input** | `pair_screen.dart` | Working | Rotating placeholder every 4s; voice icon (placeholder for v1.1) |
| **F4.2 Three modes (Food→Drink, Drink→Food, Occasion)** | `pair_screen.dart` mode pills | Working | Switching mode resets selection + query; haptic on tap |
| **F4.3 Live fuzzy search** | `_LiveSearchResults` | Working | `string_similarity` package; 0.2 threshold |
| **F4.4 Trending dishes empty state** | `_TrendingDishCard` | Working | Top 8 dishes/products from seed |
| **F4.5 Occasion grid empty state** | `_OccasionTile` | Working | 6 occasions from `Occasion` enum |
| **F4.6 Selection breadcrumb** | `_SelectionBreadcrumb` | Working | Replaces search field once selected; X to clear |
| **F4.7 Bro's Pick + alternates** | `_BrosPickPairingCard` / `_BrosPickFoodCard` + `_AlternateCard` | Working | Hero result + 3 compact alternates per query |
| **F4.8 Pairing engine (palate-aware scoring)** | `lib/features/pairing/domain/pairing_engine.dart` | Working | Weighted cosine similarity + archetype bonus + occasion modifier + frequency penalty |
| **F4.9 Food-drink interaction rules** | `_applyInteractionRule` | Working | 11 food properties × product axes; complement vs contrast strategy |
| **F4.10 Pairing explanations (natural language)** | `_generatePairingExplanation` | Working | Hand-authored sentences keyed on dominant strategy |
| **F4.11 Voice input** | Mic icon | Stubbed | Snackbar "Voice in v1.1, Bro." |

---

## 5. Scan (Label OCR)

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F5.1 Camera viewfinder + gold corner brackets** | `scanner_screen.dart` `_GoldFinder` (now white per brand-strip) | Working | Full-bleed black canvas; `CustomPaint` brackets |
| **F5.2 Animated sweep line on scan** | `_SweepLine` | Working | 1.8 s loop, gold gradient line (now white) |
| **F5.3 ML Kit on-device OCR** | `google_mlkit_text_recognition` | Working | iOS + Android |
| **F5.4 String-similarity fuzzy match against seed catalogue** | `_matchProduct` | Working | 0.25 threshold |
| **F5.5 Magnetic bottom sheet (4 phases: idle / scanning / matched / no-match)** | `_MagneticSheet` | Working | `AnimatedSwitcher` + spring curve. Heavy haptic on bottle match. |
| **F5.6 Add to journal from match** | `_MatchedSheet` button | Working | Opens BroCardSheet pre-filled |
| **F5.7 Pair from match** | `_MatchedSheet` button | Working | Routes to `/pair` |
| **F5.8 Flashlight toggle** | Top-right bolt icon | Stubbed | Snackbar "Flashlight in v1.1, Bro." |

---

## 6. Journal (BroCards)

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F6.1 Hero stats with ticker animation** | `_HeroStats` | Working | Tastings · Wines · Spirits, animated count-up via TweenAnimationBuilder |
| **F6.2 Filter pills (All / Wine / Spirits / Beer / Cocktails)** | `_JournalScreenState._filter` | Working | Selection-click haptic |
| **F6.3 BroCard timeline rows** | `_BroCardTimelineRow` | Working | Bottle thumb + name + region + date + score badge |
| **F6.4 "Buy again" indicator** | Inline | Working | Heart icon + paprika label |
| **F6.5 BroCard creation flow (multi-step)** | `BroCardSheet` (in journal_screen.dart) | Working | 6 steps: Info / Appearance / Nose / Palate / Finish / Summary. Stored in Firestore `users/{uid}/journal/{id}`. |
| **F6.6 Aroma multi-select per BroCard** | `_buildNoseStep` | Working | 5 aroma categories × 5 aromas = 25 chips |
| **F6.7 Cinematic empty state** | `_EmptyState` | Working | Full-bleed paprika gradient + dual CTA (Scan a bottle / Log manually) |
| **F6.8 Journal entry detail screen** | — | Planned | Tapping a row currently no-op; v1.1 should open full BroCard view |

---

## 7. Profile / Gamification

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F7.1 Avatar + circular XP ring** | `_HeroBlock` | Working | TweenAnimationBuilder for ring fill; paprika gradient avatar |
| **F7.2 Level archetype pill** | Same | Working (with Section B fix pending) | Currently uses goldWarm bg/border literal; needs paprika tint per audit item B7 |
| **F7.3 XP bar / level progression** | `gamification.dart` `kXpLevels` | Working | 4 levels: Curious Sibling → Aspiring Taster → Confident Pairer → Wise Elder |
| **F7.4 3-tile stats row (Tastings / Streak / Badges)** | `_StatsRow` | Working | Hides zero-stat tiles |
| **F7.5 Palate radar (gated)** | `_PalateSection` | Working | Shows only when journalEntries ≥ 3; otherwise progress bar + "We're learning your palate" |
| **F7.6 Achievement badges (20 total)** | `kBadges` in `gamification.dart` | Working | Categories: scan / journal / pairing / streak / category / challenge / special |
| **F7.7 "Next to unlock" with progress bars** | `_BadgeProgressCard` | Working | Top 2 unearned by progress |
| **F7.8 "View all 20" badges sheet** | `_showAllBadges` | Working | DraggableScrollableSheet grid |
| **F7.9 "Recently earned" badge chips** | `_EarnedBadgeChip` | Working | Last 3 earned shown |
| **F7.10 Streak tracking** | `gamificationProvider` | Working (placeholder writes) | Stream from Firestore `users/{uid}/gamification/state`. Increment logic = TODO (no current writer). |
| **F7.11 XP awarding on actions** | — | Planned | Engine to grant XP on scan / journal / pairing exists in domain but no event hooks fire it |
| **F7.12 Palate archetype assignment** | `palate_profile.dart` `PalateArchetype` | Working | 5 archetypes (BoldExplorer, CrispPurist, FruitForward, BalancedSipper, SweetTooth) |

---

## 8. Aroma Wheel ("Learn")

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F8.1 Interactive aroma wheel** | `lib/features/aroma_wheel/presentation/screens/aroma_wheel_screen.dart` | Working | Hierarchical: 6 main groups → individual aromas |
| **F8.2 Aroma taxonomy** | `lib/features/aroma_wheel/domain/aroma_taxonomy.dart` | Working | Fruity / Floral / Spice / Earthy / Oak / Vegetal etc. |
| **F8.3 Wheel surfaced from Profile or Quiz** | router `/aroma` | Working | Push route, full-screen modal |
| **F8.4 "Nose Knows" badge unlock** | `gamification.dart` SpecialCondition('all-aroma-categories') | Hidden | Condition exists, no event-fire code |

---

## 9. Settings

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F9.1 Theme toggle (light / dark)** | `_ThemeSwitch` | Working | Animated knob with spring curve |
| **F9.2 Language picker (EN / HI / MR / GU)** | `_showLanguageSheet` | Working | Modal sheet; persists via SharedPreferences |
| **F9.3 Sign out (with confirm)** | `_confirm` dialog | Working | |
| **F9.4 Delete account (with confirm)** | Same | Stubbed | Snackbar "Account deletion coming soon" — backend = TODO |
| **F9.5 Privacy policy link** | Opens external URL | Working | `url_launcher` |
| **F9.6 Terms of service link** | Same | Working | |
| **F9.7 Version display** | Inline | Working | Hard-coded `0.1.0` — should read from `package_info_plus` |
| **F9.8 "Drink responsibly. 18+" footer** | Inline | Working | |

---

## 10. Community (demoted, inline)

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F10.1 Bro Circle strip on Home** | `home_screen.dart` (covered by F3.5) | Working (placeholder data) | 4 ambient signal cards |
| **F10.2 Social proof line on product detail sheet** | `home_screen.dart` `_showProductDetail` | Working (hard-coded) | "82% of bros pair this with Indian food" — string is a placeholder |
| **F10.3 Follow / share / tasting circles / leaderboards** | — | Planned (v1.2) | Originally in PHP2 of redesign; deferred |
| **F10.4 Cask Circle event integration** | — | Planned | CHV sister venture; defer to v1.3 |

---

## 11. Internationalisation

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F11.1 4-language UI (EN / HI / MR / GU)** | `lib/l10n/generated/*` + `lib/core/l10n/l10n_extension.dart` | Working | All redesigned screens use `context.l10n` for strings |
| **F11.2 Locale persistence** | `lib/core/providers/locale_provider.dart` | Working | SharedPreferences |
| **F11.3 New 2026 redesign strings** | — | Partially translated | New copy ("Tonight's Pour", "Continue your story", etc.) currently English-only — l10n keys not yet added |

---

## 12. Theme system

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F12.1 ThemeExtension AppColors** | `lib/core/theme/app_colors.dart` | Working | 30+ tokens, light + dark instances |
| **F12.2 Brand-locked palette** | Same | Working post PR #13 | Paprika / Thunder / Salem only; gold tokens resolve to brand-legal values |
| **F12.3 Motion primitives** | `lib/core/theme/app_motion.dart` | Working | 6 durations + 5 curves (incl. spring overshoot) |
| **F12.4 Elevation system** | `lib/core/theme/app_elevation.dart` | Working | e0/e1/e2/eHero — adapts per theme |
| **F12.5 Hero text styles (displayHero, serifQuote, eyebrow, scoreNumber)** | `lib/core/theme/app_theme.dart` extension | Working | Available via `context.displayHero` etc. |
| **F12.6 `salemOnDark` + `paprikaOnDark` accessibility tokens** | — | ⏳ Pending Section B | Designed in preview, not yet in Flutter |

---

## 13. Photography pipeline

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F13.1 SDXL prompt template** | `scripts/generate-photography.js` | Working | Brand-true: dark/moody/candlelit/paprika-amber |
| **F13.2 Free Hugging Face Inference API path** | Same | Working | Dry-run mode without `HF_TOKEN` |
| **F13.3 Asset folders + pubspec registration** | `app/assets/products/`, `app/assets/dishes/` | Working | Empty (gitkeep'd); waiting for first batch |
| **F13.4 `Product.imageUrl` + `Dish` image wiring** | seed files | Planned | One-off seed update after first batch lands |

---

## 14. Notifications (FCM)

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F14.1 FCM token registration** | `firebase_messaging` integrated | Working | Permission requested via `permission_handler` |
| **F14.2 Foreground / background handlers** | — | Hidden | No notification types defined yet |
| **F14.3 Daily Bro Tip notification** | — | Planned | Cron + topic subscription |
| **F14.4 Weekly streak reminder** | — | Planned | Same |

---

## 15. Crashlytics + Analytics

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F15.1 Firebase Crashlytics** | `firebase_crashlytics` | Working | Auto crash capture |
| **F15.2 Firebase Analytics events** | `firebase_analytics` | Working | Default screen-view events; no custom events fired yet |
| **F15.3 Custom events (scan / pair / journal save)** | — | Planned | Wire on action completion |

---

## 16. Backend / Data

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F16.1 Firebase Auth + Firestore** | `firebase_options.dart` | Working | Project: `winebro` (asia-south1) |
| **F16.2 Seed product catalogue (~30 products)** | `lib/features/pairing/data/seed_products.dart` | Working | Real Indian wines + spirits + beers + globals |
| **F16.3 Seed dish catalogue (~80 dishes)** | `lib/features/pairing/data/seed_dishes.dart` | Working | Indian regional + global dishes |
| **F16.4 Aroma taxonomy** | `lib/features/aroma_wheel/domain/aroma_taxonomy.dart` | Working | 6 groups × ~5 aromas |
| **F16.5 Badge catalogue (20)** | `gamification.dart` | Working | Conditions defined; some not yet event-fired |
| **F16.6 Cloud functions backend** | — | Planned | None deployed yet |

---

## 17. Build / CI

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F17.1 GitHub Actions iOS release workflow** | `.github/workflows/ios-release.yml` | Working | flutter analyze + test + build IPA + altool upload |
| **F17.2 Codemagic iOS pipeline** | `codemagic.yaml` | Configured | Awaiting Apple activation to test end-to-end |
| **F17.3 Android signing config** | `android/app/build.gradle.kts` + `winebro-release.jks` | Working | Release builds signed; AAB at `0.1.0+2` post AD_ID strip |
| **F17.4 Play Store asset generators** | `scripts/generate-play-store-assets.js` | Working | App icon + feature graphic + 6 phone + 6 7-inch + 6 10-inch |
| **F17.5 Design preview generator** | `scripts/generate-design-preview.js` | Working | 17 screens × 2 themes; brand-true tokens |
| **F17.6 Photography generator** | `scripts/generate-photography.js` | Working (dry-run only) | Awaiting HF_TOKEN |

---

## 18. Compliance / Privacy

| Feature | Source | Status | Notes |
|---------|--------|--------|-------|
| **F18.1 iOS Privacy Manifest** | `app/ios/Runner/PrivacyInfo.xcprivacy` | Working | Mandated by Apple May 2024 |
| **F18.2 Info.plist usage strings (camera / photos / mic / tracking)** | `app/ios/Runner/Info.plist` | Working | Feature-specific copy; export-compliance flag set |
| **F18.3 Android AD_ID + AdServices stripped** | `AndroidManifest.xml` | Working | tools:node="remove" on 4 permissions |
| **F18.4 Privacy Policy hosted** | `https://winebro.web.app/privacy-policy.html` | Working | DPDPA + GDPR framework |
| **F18.5 Age gate (18+)** | Login screen tickbox | Working | |
| **F18.6 Data Safety form mapping** | `docs/PLAY-STORE-SUBMISSION.md` §4 | Documented | User pastes into Play Console |
| **F18.7 App Privacy questionnaire** | `docs/APP-STORE-SUBMISSION.md` §2 | Documented | Mirrors PrivacyInfo.xcprivacy |

---

## Tally

| Status | Count |
|--------|-------|
| Working | 67 |
| Working (placeholder data) | 5 |
| Working (with pending colour fix) | 1 |
| Stubbed | 4 |
| Hidden | 3 |
| Planned | 13 |
| Deleted | 0 |

Total features tracked: **93**.

---

## How to use this for the feature-by-feature review

When you say "review feature X", I will:
1. Open the source path(s) listed
2. Walk you through current behaviour, UI, edge cases, and gaps
3. Compare against the redesign plan + brand guide
4. Propose specific improvements with code locations
5. Add any new debt/fixes to `TRACKER.md`

Pick a feature number (e.g., "review F3.5 Bro Circle") or pick a section
(e.g., "review section 4 Pair") and we go.
