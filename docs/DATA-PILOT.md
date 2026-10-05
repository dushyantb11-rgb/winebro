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

## Stages

| # | Stage | Who | Output | Done when |
|---|---|---|---|---|
| 1 | Pick the 111 drinks | Claude | `pilot_list.json`, Firestore `pilot_candidates` | ✅ |
| 2 | Collect facts | Claude (scripts) | `facts.*` with source per field | every drink has ABV, style, region, producer with a source, or a logged gap |
| 3 | Link open data | Claude | `openData` (X-Wines, Open Food Facts, Wikidata, Commons, BJCP) | re-run `enrich-open-data.js` on the new ids |
| 4 | AI draft | Claude | `aiDraft`: notes, aromas, six scores, with the facts it used | every drink has a draft |
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
