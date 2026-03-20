# WineBro — Comprehensive Use Case Test Matrix

## Legend
- [x] = Tested & Passing
- [ ] = Needs Testing
- UNIT = Pure Dart unit test (no Firebase)
- WIDGET = Flutter widget test
- INTEG = Integration test (requires Firebase emulator)
- MANUAL = Manual device test

---

## 1. PAIRING ENGINE (Core IP)

### 1.1 Weighted Cosine Similarity
| # | Use Case | Type | Status |
|---|----------|------|--------|
| PE-01 | Identical profiles produce score ~99% (ceiling) | UNIT | [ ] |
| PE-02 | Orthogonal profiles produce score ~40% (floor) | UNIT | [ ] |
| PE-03 | Score is always clamped between 40-99 | UNIT | [ ] |
| PE-04 | Zero user profile returns floor score (40) | UNIT | [ ] |
| PE-05 | Axis weights applied correctly (acidity 1.2 > tannin 0.9) | UNIT | [ ] |
| PE-06 | A Sauvignon Blanc scores higher for Crisp Purist than Bold Explorer | UNIT | [ ] |
| PE-07 | A Lagavulin 16 scores higher for Bold Explorer than Crisp Purist | UNIT | [ ] |

### 1.2 Archetype Bonuses
| # | Use Case | Type | Status |
|---|----------|------|--------|
| PE-08 | Bold Explorer user + bold product gets +15% bonus | UNIT | [ ] |
| PE-09 | Crisp Purist user + crisp product gets +12% bonus | UNIT | [ ] |
| PE-10 | Non-matching archetype gets +0% bonus | UNIT | [ ] |
| PE-11 | Archetype bonus does not push score above 99% | UNIT | [ ] |

### 1.3 Occasion Modifiers
| # | Use Case | Type | Status |
|---|----------|------|--------|
| PE-12 | Date Night increases complexity +1.5 and body +1.0 | UNIT | [ ] |
| PE-13 | Beach/Pool decreases body -1.0, increases freshness +1.5 | UNIT | [ ] |
| PE-14 | Celebration gives sparkling wine +10% category bonus | UNIT | [ ] |
| PE-15 | Modifiers clamped to 0-10 range (no negative axes) | UNIT | [ ] |
| PE-16 | Occasion modifiers don't mutate the original profile | UNIT | [ ] |

### 1.4 Food-Drink Pairing Rules
| # | Use Case | Type | Status |
|---|----------|------|--------|
| PE-17 | High fat food + high acidity wine = positive score (contrast) | UNIT | [ ] |
| PE-18 | Spicy food + fruity/sweet wine = positive score (contrast) | UNIT | [ ] |
| PE-19 | Spicy food + high tannin wine = negative score (tannin amplifies heat) | UNIT | [ ] |
| PE-20 | High protein + high tannin = positive score (complement) | UNIT | [ ] |
| PE-21 | Light food + heavy wine = negative score (overpowers) | UNIT | [ ] |
| PE-22 | Sweet dessert + tannic red = negative score | UNIT | [ ] |
| PE-23 | Pairing strategy correctly identified as complement or contrast | UNIT | [ ] |

### 1.5 Ranking & Filtering
| # | Use Case | Type | Status |
|---|----------|------|--------|
| PE-24 | rankProducts returns sorted list (highest first) | UNIT | [ ] |
| PE-25 | rankProducts respects topN limit | UNIT | [ ] |
| PE-26 | suggestDrinkForFood blends user match (60%) + food compatibility (40%) | UNIT | [ ] |
| PE-27 | suggestFoodForDrink returns correct dish matches | UNIT | [ ] |
| PE-28 | Frequency penalty applied: -3%, -8%, -15% cap | UNIT | [ ] |

---

## 2. QUIZ ENGINE

### 2.1 Score Generation
| # | Use Case | Type | Status |
|---|----------|------|--------|
| QE-01 | Single food selection produces valid 0-10 axis scores | UNIT | [ ] |
| QE-02 | Two food selections sum contributions correctly | UNIT | [ ] |
| QE-03 | Drink selection contributions added to total | UNIT | [ ] |
| QE-04 | Chaat conditional answer contributions added when applicable | UNIT | [ ] |
| QE-05 | Min-max normalization maps to 0-10 range | UNIT | [ ] |
| QE-06 | All-same raw scores don't cause division by zero | UNIT | [ ] |

### 2.2 Slider Blending
| # | Use Case | Type | Status |
|---|----------|------|--------|
| QE-07 | Untouched sliders = quiz result (0.4*q + 0.6*q = q) | UNIT | [ ] |
| QE-08 | Override slider weights at 60% vs quiz at 40% | UNIT | [ ] |
| QE-09 | Blended scores clamped to 0-10 | UNIT | [ ] |

### 2.3 Archetype Classification
| # | Use Case | Type | Status |
|---|----------|------|--------|
| QE-10 | Body>=7 AND Complexity>=7 → Bold Explorer | UNIT | [ ] |
| QE-11 | Acidity>=7 AND Freshness>=7 → Crisp Purist | UNIT | [ ] |
| QE-12 | Fruit>=8 → Fruit Forward | UNIT | [ ] |
| QE-13 | Tannin<=3 AND Fruit>=7 → Sweet Tooth | UNIT | [ ] |
| QE-14 | All axes 3-7 → Balanced Sipper | UNIT | [ ] |
| QE-15 | Conflict: Bold Explorer vs Fruit Forward → higher combined threshold wins | UNIT | [ ] |
| QE-16 | No archetype triggered → fallback to Balanced Sipper | UNIT | [ ] |

---

## 3. AUTHENTICATION

| # | Use Case | Type | Status |
|---|----------|------|--------|
| AU-01 | Email sign up with valid credentials creates Firebase user | INTEG | [ ] |
| AU-02 | Email sign up with existing email shows error | INTEG | [ ] |
| AU-03 | Email sign in with correct password succeeds | INTEG | [ ] |
| AU-04 | Email sign in with wrong password shows error | INTEG | [ ] |
| AU-05 | Phone OTP sends verification SMS | INTEG | [ ] |
| AU-06 | Valid OTP verification succeeds | INTEG | [ ] |
| AU-07 | Invalid OTP shows error message | INTEG | [ ] |
| AU-08 | New user redirected to name screen | INTEG | [ ] |
| AU-09 | User with name but no quiz redirected to quiz | INTEG | [ ] |
| AU-10 | Fully onboarded user goes to home | INTEG | [ ] |
| AU-11 | Sign out clears state and redirects to login | INTEG | [ ] |
| AU-12 | Age verification checkbox required before submit | WIDGET | [ ] |

### 3.1 Validation
| # | Use Case | Type | Status |
|---|----------|------|--------|
| VA-01 | Invalid email format rejected | UNIT | [ ] |
| VA-02 | Password < 8 chars rejected | UNIT | [ ] |
| VA-03 | Password without uppercase rejected | UNIT | [ ] |
| VA-04 | Password without number rejected | UNIT | [ ] |
| VA-05 | Indian phone: valid 10-digit starting with 6-9 accepted | UNIT | [ ] |
| VA-06 | Indian phone: with +91 prefix normalized correctly | UNIT | [ ] |
| VA-07 | Indian phone: with 0 prefix normalized correctly | UNIT | [ ] |
| VA-08 | OTP must be exactly 6 digits | UNIT | [ ] |
| VA-09 | Display name: 2-50 characters required | UNIT | [ ] |
| VA-10 | Rating: 1-5 range validated | UNIT | [ ] |

---

## 4. ONBOARDING QUIZ (UI)

| # | Use Case | Type | Status |
|---|----------|------|--------|
| OB-01 | Step 1: Can select up to 2 foods | WIDGET | [ ] |
| OB-02 | Step 1: Cannot select more than 2 | WIDGET | [ ] |
| OB-03 | Step 2: Only appears if "Pani Puri" selected in Step 1 | WIDGET | [ ] |
| OB-04 | Step 3: Single drink selection | WIDGET | [ ] |
| OB-05 | Step 4: Sliders default to 5.0 | WIDGET | [ ] |
| OB-06 | Progress bar advances correctly | WIDGET | [ ] |
| OB-07 | Back button navigates to previous step | WIDGET | [ ] |
| OB-08 | Result screen shows radar chart with real scores | WIDGET | [ ] |
| OB-09 | Archetype name and description displayed | WIDGET | [ ] |
| OB-10 | "Let's Go, Bro!" saves profile to Firestore | INTEG | [ ] |

---

## 5. HOME SCREEN

| # | Use Case | Type | Status |
|---|----------|------|--------|
| HM-01 | Greeting shows user's name | WIDGET | [ ] |
| HM-02 | Bro's Pick comes from real pairing engine ranking | UNIT | [ ] |
| HM-03 | Trending list sorted by quality heuristic | UNIT | [ ] |
| HM-04 | Quick action buttons navigate to correct tabs | WIDGET | [ ] |
| HM-05 | Bro Tip card displays real wine education content | WIDGET | [ ] |

---

## 6. PAIR SCREEN

| # | Use Case | Type | Status |
|---|----------|------|--------|
| PA-01 | Food→Drink: Selecting Butter Chicken returns wine pairings with real scores | UNIT | [ ] |
| PA-02 | Food→Drink: Scores come from real engine (not hardcoded) | UNIT | [ ] |
| PA-03 | Drink→Food: Selecting Sula SB returns Indian food suggestions | UNIT | [ ] |
| PA-04 | Occasion: Date Night shifts profile and re-ranks products | UNIT | [ ] |
| PA-05 | Occasion: Celebration gives sparkling wine a boost | UNIT | [ ] |
| PA-06 | All match percentages are integers 40-99 | UNIT | [ ] |
| PA-07 | Bro Tips generated are contextual (not generic) | UNIT | [ ] |

---

## 7. SCANNER

| # | Use Case | Type | Status |
|---|----------|------|--------|
| SC-01 | Text search with "Sula" returns Sula products | UNIT | [ ] |
| SC-02 | Text search with "Nashik" returns wines from Nashik | UNIT | [ ] |
| SC-03 | Fuzzy matching: "glenffidich" matches "Glenfiddich" | UNIT | [ ] |
| SC-04 | Search returns top 5 results sorted by relevance | UNIT | [ ] |
| SC-05 | Empty query returns no results | UNIT | [ ] |
| SC-06 | Matched product shows full detail card | WIDGET | [ ] |

---

## 8. JOURNAL (BroCard)

| # | Use Case | Type | Status |
|---|----------|------|--------|
| JO-01 | Quick log: name + rating saves to Firestore | INTEG | [ ] |
| JO-02 | BroCard 6-step form captures all fields | WIDGET | [ ] |
| JO-03 | Appearance step: colour, clarity, intensity segmented controls | WIDGET | [ ] |
| JO-04 | Nose step: aroma chips can be selected/deselected | WIDGET | [ ] |
| JO-05 | Palate step: sweetness/acidity/tannin/body controls | WIDGET | [ ] |
| JO-06 | Finish step: star rating interactive (tap to set) | WIDGET | [ ] |
| JO-07 | Summary step: shows all collected data | WIDGET | [ ] |
| JO-08 | Journal list sorted by date descending | INTEG | [ ] |
| JO-09 | Favorite toggle persists | INTEG | [ ] |
| JO-10 | Journal entry model serializes/deserializes correctly | UNIT | [ ] |

---

## 9. PROFILE & GAMIFICATION

| # | Use Case | Type | Status |
|---|----------|------|--------|
| PR-01 | Radar chart displays 6-axis palate profile | WIDGET | [ ] |
| PR-02 | XP bar shows correct progress to next level | UNIT | [ ] |
| PR-03 | Level 0 (0 XP) = Curious Sibling | UNIT | [ ] |
| PR-04 | Level 1 (500 XP) = Aspiring Taster | UNIT | [ ] |
| PR-05 | Level 2 (1500 XP) = Confident Pairer | UNIT | [ ] |
| PR-06 | Level 3 (5000 XP) = Wise Elder | UNIT | [ ] |
| PR-07 | Level progress: 750 XP = 50% progress from L1 to L2 | UNIT | [ ] |
| PR-08 | Badge "Eagle Eye" unlocks after 1 scan | UNIT | [ ] |
| PR-09 | Badge "On Fire" unlocks after 7-day streak | UNIT | [ ] |
| PR-10 | Badge unlock check returns only NEW badges (not already earned) | UNIT | [ ] |
| PR-11 | Stats grid shows correct counts | WIDGET | [ ] |
| PR-12 | Sign out button works | WIDGET | [ ] |

---

## 10. AROMA WHEEL

| # | Use Case | Type | Status |
|---|----------|------|--------|
| AW-01 | 6 top-level categories displayed | WIDGET | [ ] |
| AW-02 | Tap category → shows subcategories | WIDGET | [ ] |
| AW-03 | Tap subcategory → shows individual aromas | WIDGET | [ ] |
| AW-04 | Back button navigates up the hierarchy | WIDGET | [ ] |
| AW-05 | Indian-specific aromas present (cardamom, tamarind, jaggery) | UNIT | [ ] |
| AW-06 | Total aroma count > 100 | UNIT | [ ] |

---

## 11. SEED DATA INTEGRITY

| # | Use Case | Type | Status |
|---|----------|------|--------|
| SD-01 | All 50 products have unique IDs | UNIT | [ ] |
| SD-02 | All 52 dishes have unique IDs | UNIT | [ ] |
| SD-03 | All product axis scores within 0-10 | UNIT | [ ] |
| SD-04 | All dish pairings reference valid product IDs | UNIT | [ ] |
| SD-05 | All products have non-empty tasting notes | UNIT | [ ] |
| SD-06 | All products have at least 1 aroma | UNIT | [ ] |
| SD-07 | All dishes have at least 1 food property | UNIT | [ ] |
| SD-08 | All dishes have at least 2 pairings | UNIT | [ ] |
| SD-09 | No duplicate product names | UNIT | [ ] |
| SD-10 | All dish pairing scores within 40-99 | UNIT | [ ] |

---

## 12. CLOUD FUNCTIONS NEEDED

| # | Function | Purpose | Priority |
|---|----------|---------|----------|
| CF-01 | Streak calculator (scheduled, daily) | Reset streak if user missed a day | HIGH |
| CF-02 | Daily discovery generator (scheduled, daily) | Pick personalized Bro's Pick per user | MEDIUM |
| CF-03 | XP validation (on write trigger) | Prevent client-side XP cheating | HIGH |
| CF-04 | Badge award trigger (on XP update) | Auto-award badges server-side | HIGH |
| CF-05 | Firestore security rules | Prevent unauthorized reads/writes | CRITICAL |
| CF-06 | User cleanup on account delete | GDPR: delete all subcollections | MEDIUM |

---

## TOTAL USE CASES: 106
- UNIT testable: 72
- WIDGET testable: 26
- INTEG testable: 8
- Cloud functions: 6
