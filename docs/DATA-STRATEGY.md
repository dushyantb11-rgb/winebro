# WineBro 2026 — Data Strategy & Action Plan

**Premise:** Data is the king. Code, design, and brand are commoditising;
the **data asset** is the only durable moat WineBro can build. Every
feature decision from this point forward is evaluated against one
question: **does it generate unique data we can defend?**

This document complements `STRATEGY-AUDIT.md` (the qualitative analysis)
with a quantitative, data-first execution plan.

Authored 2026-05-05.

---

## 0. Frame: what data WOULD be defensible?

A data asset is defensible when it satisfies four tests:

1. **Hard for incumbents to copy.** Vivino has Western pairing data;
   Indian dish ↔ wine pairing is a complete white space.
2. **Cost-asymmetric to acquire.** Each new data point costs WineBro
   pennies (one user logging one BroCard) but would cost a competitor
   thousands (commissioning a sommelier panel).
3. **Compounds over time.** N users producing M observations each
   generates N×M data — and the next user's experience improves
   because of the prior N×M.
4. **Marketable to brands.** Sula, Penfolds, Hipbar, Living Liquidz
   would pay for these insights — meaning data also becomes a
   monetisation path, not just a product input.

Below: 10 unique data assets WineBro can build. Most apps in this
category build 2–3. We're going to build all 10 systematically.

---

## 1. The 10 unique data assets

Each row: what we generate, why it's defensible, who would pay for it,
which feature(s) produce it.

| # | Data asset | Why defensible | Buyer | Source feature(s) |
|---|------------|---------------|-------|-------------------|
| **D1** | **Indian-dish ↔ bottle pairing success matrix** — for every dish × bottle pair, a "tried & rated" score from real Indian palates | Vivino has zero of this. Pairing is hand-coded by Western sommeliers worldwide. | Wine importers (Sula, Grover, Indian distributors of Penfolds) — to prioritise SKUs for Indian retail | Pair recommendation acceptance + post-tasting BroCard with foodPaired |
| **D2** | **India regional palate map** — Mumbai vs Delhi vs Bangalore vs Chennai palate axes, archetypes, drink preference | Demographic-first; unprecedented in India. Lifestyle research firms today guess. | Brand launches into India ("which regions to test first"), restaurant chains, retail planning | Quiz + journal entries + auth-derived city/region |
| **D3** | **Indian-context aroma vocabulary** — when an Indian taster says "smoky," do they mean peat (Western) or tandoor/bharta? | Cultural-linguistic data. WSET maps don't include it. | Wine educators, brand storytelling, voice translation models | BroCard aroma selection + Aroma Wheel exploration + (later) free-text tasting notes |
| **D4** | **Price-band consumption truth** — what bottles do bros at ₹500, ₹1500, ₹3500, ₹10000 actually drink and rate? | Survey data is unreliable; behavioural data is gold. | Brand marketing teams, importers, retail buyers | BroCard price tag + Buy-again flag + Buy click on affiliate |
| **D5** | **Cross-category preference graph** — "Lagavulin lovers also love → ?" | Multi-category single-app is rare. Distiller is spirits-only; Vivino is wine-only. | Affiliate partners, brand discovery campaigns | BroCards across categories + Pair Drink→Food selections |
| **D6** | **Pairing success rate** — when WineBro recommended X for dish Y, did the user actually try it and rate ≥4★? | Almost no app tracks recommendation outcomes. Vivino doesn't even try. | This is THE data asset. It self-improves the engine. | Pair → Save/Buy → BroCard with foodPaired link |
| **D7** | **Restocking behaviour** — who buys the same bottle 2nd, 3rd, 4th time? | Brand loyalty data at the SKU × user × time axis. | Brands measuring loyalty programmes, churn analysis | Buy-again flag + repeat-scan within window + restock notification ack |
| **D8** | **Discovery sequences** — typical journey from first scan → 10th BroCard → first new category | Cohort analysis to identify activation patterns. | Internal product team + sold to brands as "user journey research" | Event log of every action |
| **D9** | **Aroma development trajectory** — how an individual user's aroma vocabulary expands month over month | Personalised education baseline. | Wine schools (WSET India), brand storytelling | BroCard aroma selections over time + Aroma Wheel exploration timestamps |
| **D10** | **Occasion-context drinking patterns** — Diwali pairings vs Anniversary vs Friday-night vs Weekend-brunch | Cultural occasions specific to India that no other app captures. | Brands' seasonal campaigns, festive packaging decisions | BroCard occasion field + Pair Occasion mode |

**Note on D6:** This is the deepest moat. Most apps recommend in a vacuum
and never learn whether the recommendation worked. By instrumenting the
**Pair → Try → Rate** loop, we close a feedback cycle that improves the
engine and produces data brands can't get elsewhere.

---

## 2. Phase plan — what we ship, what we capture

Five phases, ordered by data-yield × buildability. Each phase has:
- **Features shipped** — the user-visible work
- **Data captured** — the new events / fields / dimensions
- **What it unlocks** — the data asset(s) this phase populates
- **Estimated effort** — engineering days

### Phase 0 — Instrumentation foundation (1 week, blocking)

**Without instrumentation, no other phase has measurable impact. This
must ship first.**

**Features shipped:**
- Firebase Analytics custom events (~22 event types)
- BigQuery export enabled
- Default Looker Studio dashboard
- Server-side analytics validation (every event also written to a
  Firestore `events` collection for cross-checking)
- Privacy-compliant user-property setting

**Data captured (event schema):**

| Event | Critical params |
|-------|-----------------|
| `app_open` | source (organic / notification / deeplink), session_id |
| `quiz_started` | — |
| `quiz_question_answered` | step, question_id, answer_id, time_taken_ms |
| `quiz_completed` | total_time_ms, archetype, axes_json |
| `quiz_skipped` | step_at_skip |
| `home_view` | session_id, has_journal_entries, time_bucket |
| `tonights_pour_view` | product_id |
| `tonights_pour_action` | action (tap / why_tap / dismiss), product_id |
| `emotion_tile_tap` | emotion (cooking / hosting / sipping) |
| `continue_story_tap` | last_product_id, suggested_product_id, days_since_last |
| `bro_circle_card_tap` | signal_type, product_id |
| `pair_search_typed` | query_length, mode |
| `pair_mode_changed` | from, to |
| `pair_dish_selected` | dish_id, dish_category |
| `pair_drink_selected` | product_id |
| `pair_occasion_selected` | occasion |
| `pair_result_view` | result_type (food→drink / drink→food / occasion), top_match_pct, products_shown |
| `pair_result_action` | product_id, action (buy / save / log / pair / dismiss), match_pct |
| `scan_opened` | source (fab / journal_empty / scan_match_button) |
| `scan_camera_granted` | first_time |
| `scan_label_captured` | ocr_text_length |
| `scan_match_attempt` | match_score, top_3_candidates_json |
| `scan_match_result` | success (bool), corrected_to_product_id (if user fixed) |
| `brocard_quick_logged` | product_id, rating, source (scan / pair / manual) |
| `brocard_pro_started` | source |
| `brocard_pro_step_completed` | step, dropoff_likely (bool) |
| `brocard_pro_completed` | total_time_ms, fields_filled_count |
| `brocard_buyagain_toggled` | product_id, value |
| `brocard_foodpaired_set` | product_id, dish_or_food_string |
| `aroma_wheel_opened` | source |
| `aroma_category_explored` | category, dwell_ms |
| `aroma_selected_in_brocard` | aroma_name, category |
| `badge_unlocked` | badge_id, time_since_install_days |
| `streak_extended` | new_streak_days |
| `streak_lost` | lost_streak_days |
| `notification_tapped` | type, hours_since_send |
| `restock_action` | product_id, action (acknowledge / dismiss / open_shop) |
| `affiliate_buy_clicked` | product_id, partner, price_inr |
| `voice_note_recorded` | duration_ms, transcribed_words |
| `feedback_pairing_correct` | product_id, dish_id, rating |

User properties:
- `archetype` (BoldExplorer / CrispPurist / FruitForward / BalancedSipper / SweetTooth)
- `level`, `xp`, `streak`, `total_brocards`, `total_scans`, `total_pairs`
- `quiz_completed_at`, `install_date`
- `palate_fruit`, `palate_acidity`, `palate_body`, `palate_tannin`,
  `palate_freshness`, `palate_complexity` (six axes 0–10)
- `preferred_categories` (csv), `region` (city)
- `last_active_date`

**Data captured server-side (Cloud Function on event write):**
- `event_id`, `user_id_hashed`, `event_name`, `params_json`,
  `session_id`, `device_info`, `app_version`, `timestamp`

**What it unlocks:** All 10 data assets become *measurable*. Today they're
invisible.

**Effort:** 5–7 engineering days.

---

### Phase 1 — Data-generating features (2-4 weeks)

**Goal:** ship features that close the broken loops AND produce the
high-priority data assets.

**Features shipped:**

1. **Quick-log BroCard mode** (closes journal habit gap; produces D1, D4)
   - 1-tap "Quick log" button alongside the Pro 6-step
   - Asks only: name (autocomplete or scan-prefill) + ⭐ rating
   - Optional: "What did you eat with it?" (1 tap, autocomplete from dish list)
   - Optional: "Buy again?" (yes/no/maybe)
   - Saves immediately; opens "Pro mode upgrade" CTA at the bottom for
     users who want to add notes later
   - **Data capture:** every Quick log = 1 row in `brocard_quick_logged`
     event + sparse Firestore document. The `foodPaired` micro-question
     is the engine of D1 (Indian dish-bottle pairing matrix).

2. **Buy / Save / Remind buttons on Pair results** (closes Pair dead end; produces D6, D5)
   - Bro's Pick + alternates each show: "Buy ₹650 →" (placeholder URL
     until partner BD), "Save for later", "Remind me at the store"
   - Save → wishlist Firestore collection
   - Remind → geofence trigger ("you're near a liquor store") OR
     calendar reminder (user's choice)
   - Buy → opens partner URL (affiliate referral parameter appended)
   - **Data capture:** `pair_result_action` event with action type. This
     produces D6 — the recommendation success rate matrix.

3. **"Did Bro get it right?" feedback after pairing** (produces D6 deeply)
   - 24h after a `pair_result_action` with action = save/buy, push:
     "Did the Sula Rasa Shiraz work with butter chicken?" ⭐⭐⭐⭐⭐
   - 1-tap response. Saves to `feedback_pairing_correct` event.
   - **Data capture:** the closed feedback loop. This is the gold mine.

4. **3 push notification types** (closes trigger gap)
   - **Daily Bro Tip** — 8pm IST, randomised per archetype
   - **Streak-loss anxiety** — sent at 9pm if streak about to lapse
   - **Tonight's Pour** — 7pm if user has been inactive for >3 hours
   - **Data capture:** `notification_tapped` event with type + hours_since_send

5. **Restock surface for "Buy again"** (closes D2 dead end)
   - Home: "Restock — items you've marked Buy again that you haven't
     scanned/logged in 30 days"
   - Push: weekly Sunday 11am — "Time to restock your Antinori?"
   - **Data capture:** `restock_action` event

**Data captured (new):**
- `feedback_pairing_correct` — the engine input for D6
- `pair_result_action` populates D6
- `brocard_quick_logged` populates D1, D4 at scale
- `restock_action` populates D7

**What it unlocks:**
- **D1** Indian-dish-bottle pairing matrix — first 1000 quick-logs
  populate it
- **D6** Pairing success rate — first feedback responses come in
- **D7** Restocking behaviour — buy-again actually means something now
- **Habit:** D7 retention forecast goes from 15% → 30% with push alone

**Effort:** 12–16 engineering days. Highest ROI work in the backlog.

---

### Phase 2 — Calibration + enrichment (4-6 weeks)

**Goal:** start producing the harder, more defensible data assets that
require active capture.

**Features shipped:**

1. **Aroma calibration mini-quizzes** (produces D3, D9)
   - Inside Aroma Wheel: "Quick quiz — taste this Cabernet right now.
     Which 3 aromas hit hardest?" 5 chips → tap up to 3.
   - "Bonus: any of these in your culture but not in the Western
     vocabulary?" free-text optional.
   - Gamified: 5 calibrations = badge "Calibrated Nose."
   - **Data capture:** `aroma_calibration_response` event with
     product_id, aromas_chosen, free_text (optional) +
     `aroma_vocabulary_extension` event for free-text suggestions

2. **Photo capture in BroCard** (produces D-meta: image training data)
   - Quick-log Pro toggle: "Add a photo?" — accepts label photo OR
     full-bottle shot
   - Stored in Firebase Storage `users/{uid}/brocard_photos/`
   - **Data capture:** photo URL on BroCard. After ~1000 photos we have
     a training set for an in-house scanner that works on bottles
     outside the Western catalogue.

3. **Restaurant mode** (produces D10, D6 in restaurant context)
   - "I'm at a restaurant" toggle on Home
   - When on: Scanner switches to menu-OCR mode (extracts dish names);
     Quick-log auto-tags `consumption_context = restaurant`
   - **Data capture:** `restaurant_mode_session` event, restaurant
     name (typed or geocoded), dishes ordered, drinks paired

4. **Voice notes during tasting** (produces D3, D9 deeply)
   - 30-second voice recording on BroCard creation
   - On-device speech-to-text (free) → free-text tasting notes
   - **Data capture:** transcribed text → mined for vocabulary
     extension (Indian-context terms not in Western vocabulary)

5. **Pre-quiz one-question seed** (improves cold start; produces D2)
   - First-launch screen, before sign-in: "What did you drink last
     time you celebrated?" 6 options (red wine / white wine / whisky
     / gin / beer / cocktail). Seeds the palate for first session.
   - **Data capture:** `prequiz_seed_response` event

6. **Cross-platform consumption survey** (produces D5)
   - Inside Profile → "Help us know you better" — 30-second 5-question
     survey: "Which of these have you tried? (multi-select)" with
     icons of 30 popular bottles spanning categories.
   - **Data capture:** `cross_category_history_recorded` event

**Data captured (new):**
- `aroma_calibration_response`
- `aroma_vocabulary_extension` (free-text suggestions for Indian context)
- BroCard photo URLs (Firebase Storage)
- `restaurant_mode_session` events
- Voice-note transcriptions (mined for vocabulary)
- `prequiz_seed_response`
- `cross_category_history_recorded`

**What it unlocks:**
- **D3** Indian-context aroma vocabulary — actually populated
- **D5** Cross-category graph — populated from survey + repeated logging
- **D9** Aroma development trajectory — starts compounding
- **D10** Occasion-context patterns — restaurant + celebration data

**Effort:** 18–25 engineering days.

---

### Phase 3 — Network + depth (6-12 weeks)

**Goal:** turn synthetic Bro Circle into real social, build the
"Vivino moat for India."

**Features shipped:**

1. **Manual seed: 100 influencer BroCards** (produces D1, D6 critical mass)
   - BD operation, not engineering: hire / engage 100 wine/spirits
     creators in India. Free Pro tier in exchange for 20 BroCards each.
   - **Data capture:** 2000 BroCards instantly = critical mass for D1.

2. **Friend graph + "Bros I follow"** (produces D5, D8 + network effect)
   - Phone-contact import → "Bros you may know"
   - Follow / unfollow primitive
   - "Friends who recently scanned X" surfaces in product detail
   - **Data capture:** `follow_relation` events, `friend_signal_view`

3. **Real Bro Circle replacing synthetic** (produces D8 social graph)
   - Replace synthetic provider with real Firestore aggregations
   - Anonymised by default; opt-in to be visible
   - **Data capture:** `bro_circle_real_engagement`

4. **Annual review / Yearly Wrap-up** (produces D9 retention + D8 cohort)
   - End-of-year: "Your year in tasting" — animated, shareable
   - Spotify-Wrapped pattern. Drives D9 vocabulary insight + viral share.
   - **Data capture:** `yearly_wrap_shared` event with platform

5. **Brand-side dashboard (B2B)** (productises D1, D2, D4 directly)
   - Web app for brand reps: "Sula Rasa Shiraz dashboard — pairings
     people try, regions buying, archetype distribution"
   - **Initial revenue:** ₹50,000/brand/month → 10 brands = ₹5L MRR
   - **Data capture:** B2B usage events for product feedback

**Data captured (new):**
- `follow_relation`, `friend_signal_view`
- Real `bro_circle_real_engagement` (replaces synthetic)
- `yearly_wrap_shared`
- B2B telemetry separate path

**What it unlocks:**
- **D8** Discovery sequences — real cohort behaviour data
- **Social moat** — network effect kicks in
- **First B2B revenue** from dashboard subscriptions

**Effort:** 30–45 engineering days + BD ops separately for influencer seeding.

---

### Phase 4 — Premium tier + monetisation (3-4 weeks, parallelizable)

**Goal:** monetise so Phases 1–3 are self-funding.

**Features shipped:**

1. **Premium tier** (₹299/month)
   - Unlocks: unlimited scans (free has 10/month), AI sommelier chat,
     deep palate analytics, ad-free experience, exportable BroCards as
     PDF, "Pro Bro" insights ("you tend to over-rate Italian wines vs
     French — try blind tasting these 3 to recalibrate")
   - **Data capture:** `subscription_started` / `subscription_churned`
     events, `feature_gated_blocked` events to find friction

2. **Affiliate partner integration** (Living Liquidz / BlackBook / Hipbar)
   - "Buy" buttons populate with real partner URLs and tracking IDs
   - Commission tracking per click → BigQuery
   - **Data capture:** `affiliate_buy_clicked` (Phase 0) becomes
     monetisable

3. **Brand sponsored Tonight's Pour** (clearly labelled)
   - "Tonight's Pour, sponsored by Sula" — never mixed organic + paid
   - **Data capture:** `sponsored_pour_view`, `sponsored_pour_action`

**Data captured (new):**
- `subscription_started`, `subscription_churned`,
  `feature_gated_blocked`
- Affiliate click + conversion via partner postback
- Sponsored content metrics

**What it unlocks:**
- **Revenue:** Pro at ₹299 × even 1% of users at 50k MAU = ₹1.5L MRR
- **Data:** premium users tend to be P3 sommeliers — produce richest
  data per user

**Effort:** 12–18 engineering days.

---

## 3. Action plan — sprint-by-sprint

Translating phases into 2-week sprints. Each sprint is 8 working days
of focus.

### Sprint 1 (weeks 1-2) — Instrumentation + Quick Log

| Day | Output |
|-----|--------|
| 1 | Firebase Analytics events scaffold (22 events) — all the typing logic in `lib/core/analytics/` |
| 2 | BigQuery export config + Looker Studio dashboard skeleton |
| 3 | Wire events to all existing screens (auto-fire on page view, quiz step, scan, pair) |
| 4 | Define `users/{uid}/events/{id}` Firestore mirror collection (audit trail) |
| 5 | Quick-log BroCard mode UI |
| 6 | Quick-log save logic + analytics fire |
| 7 | "Pro mode upgrade" CTA + auto-prefill from quick log |
| 8 | QA + first dashboard review |

### Sprint 2 (weeks 3-4) — Pair loop closure + push

| Day | Output |
|-----|--------|
| 1 | Pair result Buy / Save / Remind buttons UI |
| 2 | Wishlist Firestore schema + Save flow |
| 3 | Remind flow (calendar invite + geofence stub) |
| 4 | Buy URL handler with partner placeholder + affiliate event |
| 5 | Cloud Function: `dailyBroTipPush` (8pm IST topic broadcast) |
| 6 | Cloud Function: `streakLossWarning` + `tonightsPourMorning` |
| 7 | Notification tap deep-link routing |
| 8 | QA + fire-drill on push delivery |

### Sprint 3 (weeks 5-6) — Restock + feedback loop

| Day | Output |
|-----|--------|
| 1 | "Restock" Home tile + Firestore wishlist→restock query |
| 2 | Weekly restock push (Sunday 11am) |
| 3 | "Did Bro get it right?" 24h-after-save push |
| 4 | Inline feedback star-rate UI on push tap |
| 5 | `feedback_pairing_correct` event + recommendation engine consumes it |
| 6 | Pair engine v1.1: weight successful pairs higher in cosine similarity |
| 7 | Buy-again toggle wire to push schedule |
| 8 | QA + first D6 dashboard tile |

### Sprint 4 (weeks 7-8) — Aroma calibration + photos

| Day | Output |
|-----|--------|
| 1-2 | Aroma calibration mini-quiz UI (in Aroma Wheel) |
| 3 | Free-text aroma extension capture |
| 4 | "Calibrated Nose" badge + condition logic |
| 5 | BroCard photo capture (camera + gallery) |
| 6 | Firebase Storage rules + photo upload |
| 7 | Restaurant mode toggle + menu-OCR pipeline |
| 8 | QA + dashboard updates |

### Sprint 5 (weeks 9-10) — Voice notes + cross-category survey

| Day | Output |
|-----|--------|
| 1-2 | Voice recording in BroCard + on-device STT |
| 3 | Vocabulary extraction job (Cloud Function) |
| 4 | Pre-quiz seed screen |
| 5 | Cross-platform consumption survey UI |
| 6-7 | Data pipeline for D3/D5/D9 dashboards |
| 8 | QA |

### Sprint 6 (weeks 11-12) — Premium tier scaffolding

| Day | Output |
|-----|--------|
| 1 | Razorpay subscription integration |
| 2 | Premium gate state in Riverpod + Firestore |
| 3 | Scan limit (10/month free) |
| 4-5 | AI sommelier chat (Anthropic API integration) |
| 6 | Pro Bro insights screen |
| 7 | Subscription dashboard / management |
| 8 | QA |

### Sprint 7-8 (weeks 13-16) — Influencer seeding + friend graph

(BD-heavy + engineering — runs in parallel with above where possible)
- Onboarding 100 influencers
- Friend graph primitive
- Real Bro Circle replaces synthetic

### Sprint 9-10 (weeks 17-20) — Brand-side dashboard

- B2B web app for brand reps
- First 5 paying brand customers

### Sprint 11-12 (weeks 21-24) — Yearly Wrap-up + polish

- Annual review feature
- Performance + a11y polish
- Pre-launch readiness

---

## 4. Data governance + privacy

Without a privacy spine, data collection becomes a liability.

### Principles
1. **Anonymous by default in aggregations.** Bro Circle, public-feed,
   brand dashboards never see user names.
2. **Explicit consent for B2B sharing.** Settings toggle: "Help WineBro
   share anonymised insights with wine brands?" Default = off; reward
   for opting in (e.g., 1 month Pro free).
3. **Right to delete.** Already in F1.7 (Stubbed); becomes mandatory in
   Phase 0 — every data point must be deletable on demand.
4. **DPDPA + GDPR compliance** — already declared in submission packs.
   Phase 0 should make it real with a "Download my data" + "Delete my
   data" API endpoint.
5. **Brand contracts must specify aggregation thresholds** — never
   release a slice with N < 50 users (re-identification risk).

### Schema for opt-in
```
users/{uid}/privacy:
  shareWithBrands: bool (default false)
  shareInBroCircle: bool (default true — but anonymous)
  allowVoiceTranscription: bool (default true)
  optInRewards: array<string> (e.g., ["pro_month_for_brands_optin"])
```

---

## 5. Defensibility tracker — when does the moat get real?

Targets to know we've built the moat:

| Asset | Year-1 target | Year-2 target |
|-------|---------------|---------------|
| **D1** Indian-dish ↔ bottle pairing matrix | 50,000 dish-bottle observations | 500,000 |
| **D2** India regional palate map | 5,000 users with city + completed quiz | 50,000 |
| **D3** Indian aroma vocabulary | 200 unique non-Western aroma terms | 1,000 |
| **D4** Price-band consumption | 10,000 priced BroCards | 100,000 |
| **D5** Cross-category graph | 5,000 users with ≥3 categories | 50,000 |
| **D6** Pairing success rate | 5,000 feedback responses | 100,000 |
| **D7** Restocking | 1,000 restock events | 20,000 |
| **D8** Discovery sequences | 5,000 cohort journeys | 50,000 |
| **D9** Aroma development | 1,000 users with ≥3-month history | 10,000 |
| **D10** Occasion patterns | 3,000 occasion-tagged BroCards | 30,000 |

**At Year-1 targets**, the brand-side dashboard becomes credibly
sellable at ₹50,000/month. That's the inflection point where data
becomes revenue, not just a moat.

---

## 6. What to instrument FIRST if I had to pick three events

If only three events get wired in the very first week:

1. **`pair_result_action`** — without this, we have no D1, D6, D8 ever.
   Single most valuable event in the whole system.
2. **`brocard_quick_logged`** with foodPaired field — populates D1 at scale
   the moment Quick log ships.
3. **`feedback_pairing_correct`** — closes the recommendation feedback
   loop. Without it, the engine never improves on real-world outcomes.

Everything else is downstream of these three.

---

## 7. Action plan synced to TRACKER.md

Top 12 items now in the master tracker:

| # | Item | Phase | Effort (days) |
|---|------|-------|---------------|
| C1 | Wire Firebase Analytics events scaffold | 0 | 2 |
| C2 | BigQuery export + Looker Studio dashboard | 0 | 2 |
| C3 | Quick-log BroCard mode | 1 | 3 |
| C4 | Buy/Save/Remind on Pair results | 1 | 3 |
| C5 | 3 push notification types | 1 | 3 |
| C6 | "Did Bro get it right?" 24h feedback push | 1 | 2 |
| C7 | Restock surface (Home tile + push) | 1 | 2 |
| C8 | Aroma calibration mini-quizzes | 2 | 3 |
| C9 | BroCard photo capture | 2 | 2 |
| C10 | Restaurant mode | 2 | 4 |
| C11 | Voice notes + STT extraction | 2 | 3 |
| C12 | Premium tier (Razorpay + gates + AI sommelier) | 4 | 8 |

Cross-referenced from `TRACKER.md` Section G.

---

## Closing — strategic posture

**Code we ship in 2026 is forgettable. Data we accumulate is forever.**
Every feature in this plan is selected for two reasons: it improves the
user-visible product, AND it generates data we can monetise. If a
proposed feature passes only one test, we deprioritise it.

In 12 months WineBro should have:
- 100k MAU
- 500k BroCards logged
- 50k pairing-feedback responses (D6)
- 200 non-Western aroma terms catalogued (D3)
- 10 paying brand customers on the dashboard (₹5L MRR floor)
- 1% Pro conversion (₹1.5L MRR floor)
- Combined ARR run-rate: ~₹1Cr

That's the data + revenue thesis. The strategy audit (`STRATEGY-AUDIT.md`)
explains the *why*. This document is the *how*.
