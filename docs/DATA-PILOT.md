# WineBro data pilot: 111 drinks

Goal: a drinks database that is ours, where every value is genuine and
says where it came from. Started 2026-10-05.

## Rules

1. **Facts are collected, not written.** Alcohol %, grape, region, style,
   producer, pack size come from a named source: the producer's own site
   or tech sheet, an official state list, or an open dataset.
2. **We copy facts only.** No copying of other sites' tasting notes,
   reviews or photos. Respect each site's terms and robots.txt. Photos
   only with an open licence and a credit line.
3. **AI drafts, a person approves.** AI may draft tasting notes and the
   six taste scores, marked `aiDraft`. A draft is never shown as fact.
4. **Only sommelier-approved rows are `verified`.** The app labels
   anything not verified as "not yet checked by a sommelier".
5. **Every value keeps its source**, link and date. When sources
   disagree, both values are kept and the row is flagged.

## The list (stage 1, done)

`tool/pilot/pilot_list.json`, 111 drinks:

| Group | Count | Why it is in |
|---|---|---|
| Already in the app | 55 | Existing catalogue |
| Top-selling Indian spirits | 24 | Drinks International Millionaires' Club 2025 (2024 sales) |
| Premium Indian single malts | 3 | Indri, Godawan, Amrut |
| Indian wines with outside data | 17 | In X-Wines (CC0) or Decanter 2025 Silver |
| Major beers sold in India | 12 | Listed by KSBCL Karnataka |

51 of the 56 new drinks were matched to an exact official name and item
code in the KSBCL Karnataka list. Not found there (check another state
list): 8PM Premium Black, 1965 rum, Contessa rum, Indri Trini, Grover
Reserve Collection Chenin Blanc.

## Stage 2 result (2026-10-05)

Script: `tool/pilot/collect_facts.py` → `tool/pilot/facts.json` → Firestore `pilot_candidates/{id}.facts`.

| Fact | Source | Drinks |
|---|---|---|
| Official name, supplier, pack sizes | KSBCL Karnataka price list | 51 |
| Wine ABV | Kerala BEVCO list, declared proof x 4/7 | 12 |
| Wine ABV, grapes, region, body, acidity, food types | X-Wines (CC0) | 13 |
| ABV from the producer's own page | Amrut, Carlsberg Group | 3 |

What we learned:
- **Kerala "proof" is real only for wine.** Every beer shows exactly 5.0% or
  6.0% and every spirit 42.86%; Paul John Bold (46% on the label) also shows
  42.86%. For beer and spirits it is the excise band, so it is not used.
- **Indian producer websites do not publish ABV.** 3 of 39 spirits and beers
  had it on an official page; the rest are age-gated, blocked or have no specs.
- **Wine ABV differs by about 0.5% between sources**, which is normal between
  vintages. Both values are kept.

So for Indian spirits and beer the genuine source is the **bottle label**.
Next step proposed: photograph labels (shop visit or users' scans in the app),
read ABV and pack size with the scanner's OCR, and store them as
`facts.abv` with source "label photo" and the photo itself.

## Stage 4 result (2026-10-05)

Run inside a Claude Code session (no API key): three independent estimators,
each on all 111 drinks from a different angle (measured facts / style norms /
comparison with scale anchors); code compared them (`combine_estimates.py
round2`); a reviewer settled disagreements and hard-fact conflicts with a
stated reason; code re-checked and set confidence (`final`). Stored in
Firestore `pilot_candidates/{id}.aiEstimate`, status `estimated`. The API
version of the same pipeline is `ai_estimate.py`.

| Confidence | Drinks | Meaning |
|---|---|---|
| high | 31 | estimators agree within 1, a hard taste fact (X-Wines band or BJCP style) backs it, reviewer saw no doubt |
| medium | 76 | consistent, but scored from style knowledge only (all 26 whiskies, all brandies and rums) |
| low | 4 | conflicts with a source left open, or little-known drinks: Fratelli Shiraz Rosé, Sula Sauvignon Blanc, SDU Madera Shiraz, Winery 52 Red |

Notes:
- The three estimators are the same model, so their close agreement (110 of
  111 within 1 point) shows consistency, not accuracy. That is why "high"
  also needs a hard fact.
- The reviewer kept 4 values against X-Wines bands with reasons (e.g. a rosé
  cannot be "Full-bodied"); 2 of those stay as open conflicts.
- Data issue found: Open Food Facts lists Corona Extra at 1.36% ABV (wrong;
  ignored).
- App label for these: "Estimated from published facts" + confidence. Only a
  sommelier review makes a drink `verified`.

## Stages

| # | Stage | Who | Output | Done when |
|---|---|---|---|---|
| 1 | Pick the 111 drinks | Claude | `pilot_list.json`, Firestore `pilot_candidates` | ✅ |
| 2 | Collect facts | Claude (scripts) | `facts.*` with source per field | ✅ first pass; ABV gap for Indian spirits and beer needs label photos |
| 3 | Link open data | Claude | `openData` (X-Wines, Open Food Facts, Wikidata, Commons, BJCP) | ✅ `--matches tool/pilot/open_data_matches.json --collection pilot_candidates` |
| 4 | AI estimate | Claude | `aiEstimate`: notes, aromas, six scores, confidence, inputs and all rounds | ✅ 111 estimated (2026-10-05) |
| 5 | Sommelier review | Sommelier | approve / edit / reject per drink | 111 reviewed |
| 6 | Publish | Claude | approved rows copied to `products` with `verified: true` | app shows them |

## Data shape (Firestore `pilot_candidates/{id}`)

```
name, category, brand, reason, reasonDetail, ksbcl{officialName,itemCode,ml}
status: selected | facts | drafted | in_review | approved | rejected
facts:   { abv: {value, source, url, date}, region: {...}, ... }
openData: same as products.openData
aiDraft: { tastingNotes, aromas, fruit..complexity, model, date, inputs }
review:  { by, date, decision, changes }
```

## Needs a person

- **A sommelier** for stage 5. Checking a draft takes a few minutes per
  drink, much less than writing one.
- **Agreement from Dushyant** on the rules above, especially rule 3.
