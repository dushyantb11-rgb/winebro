# GrapeMinds extraction plan (free key: 250 requests / month)

Source: GrapeMinds Wine API, base `https://api.grapeminds.eu/public/v1`, header `Authorization: Bearer <key>`,
5 requests/second. Docs: https://grapeminds.eu/developers/endpoints. Catalogue: 311,480 wines, 84,227 producers,
2,165 regions, 2,001 grapes. **Wines only** — nothing for whisky, rum, gin, brandy, vodka, beer (62 of our 111 drinks).

## 1. What each call gives us

| Call | Cost | Returns | Use for WineBro |
|---|---|---|---|
| `GET /ping` | 1 | key check | once |
| `GET /coverage?country=IN` | 1 | counts of regions, producers, wines, colours, types for India; `enrichment` counts (how many already have grapes / descriptions) | decides how big the Indian pull is |
| `GET /regions?country=IN` | 1 | all Indian regions (id, name) | region ids for listing |
| `GET /producers?country=IN&per_page=100` | 1 per 100 | Indian producers (id, name, title) | producer ids; match Sula, Grover Zampa, Fratelli, York, Charosa, KRSMA, Vallonné, Big Banyan, Chandon, Myra… |
| `GET /wines?region_id=…&per_page=100` | 1 per 100 wines | **catalogue facts**: id, LWIN, display_name, colour, type, sub_type, residual_sugar, producer, region | the cheap bulk layer: one call = up to 100 wines |
| `GET /wines/search?q=…&limit=100` | 1 per query | name search (imports: Jacob's Creek, Penfolds, Yellow Tail, Mondavi…) | match our imported wines |
| `GET /wines/{id}` (Accept-Language en) | **1 per wine** | grapes, description, tasting_notes, pairing, `flavor_profile` {sweetness, acidity, tannins, alcohol, body, finish} | the expensive layer; description/notes/pairing are **generated on demand** (AI), flavour profile provenance to confirm |
| `GET /drinking-periods/{id}` | 1 per wine | drinking window in years after vintage | low value for us (NV / everyday wines); skip |
| `GET /producer-insights/{id}` | 1 per producer | founded year, hectares, certifications, website, coordinates, intro text | genuine producer facts for ~10 Indian producers |
| `GET /region-insights/{id}` | 1 per region | summary, climate, signature styles, key grapes | 4–6 Indian regions; editorial text for region cards |
| `POST /photo/analyze` | Enterprise only | label recognition | not on our plan |
| `POST /licence/{wine_id}` | metered, ~€0.38 per wine | permanent storage right for that wine's data | **needed before we keep GrapeMinds rows in Firestore** (see §4) |

## 2. Budget: 250 calls, ~200 planned, 50 reserve

| Phase | Calls | What we get |
|---|---:|---|
| 0 Check | 3 | ping, India coverage, Indian regions |
| 1 Indian catalogue list | 6–10 | every Indian wine (id, LWIN, name, colour, type, sugar, producer, region) — probably 300–600 wines at 100 per call; plus Indian producers (1–2 calls) |
| 2 Match our 51 wines | 10–15 | Indian ones matched from the list for free; `/wines/search` for ~12 imported wines (Jacob's Creek, Penfolds, Yellow Tail, Mondavi, Cloudy Bay, Antinori, Catena, Fratelli TILT is Indian…) |
| 3 Detail for our wines | ≈51 | grapes, flavour profile, description, tasting notes, pairings for each matched wine |
| 4 Detail for expansion candidates | ≈80 | the 80 most relevant Indian wines we do **not** have yet (choose by producer/colour spread) — gives WineBro its first real catalogue growth |
| 5 Producer & region insights | ≈16 | 10 producers + 6 regions |
| Reserve | ≈50 | retries, second-language pull, surprises |

Rule: one call is never repeated. Every response is cached on disk; the tool refuses to call once the month's
ledger reaches the budget.

## 3. Mapping into WineBro (`products/{id}`)

| GrapeMinds | WineBro field | Status we show |
|---|---|---|
| `lwin`, `id` | `openData.grapeminds.lwin`, `.id` | identity (fact) |
| `grapes[]` | `grapeVariety` (if empty) + `openData.grapeminds.grapes` | fact |
| `producer`, `region`, `sub_type`, `residual_sugar` | `openData.grapeminds.*`, fill `region`/`subcategory` when empty | fact |
| `flavor_profile.acidity/tannins/body` (0–10) | compare with our estimated `acidity`, `tannin`, `body`; adopt when ours is unreviewed; keep both | "Scores from GrapeMinds" only after we confirm how they are made (ask them: expert, crowd or model) |
| `flavor_profile.sweetness/alcohol/finish` | `openData.grapeminds.profile` (no direct axis) | shown in Open facts |
| `description`, `tasting_notes` | `openData.grapeminds.notes` — **not** copied into `tastingNotes` | labelled "GrapeMinds, generated text" |
| `pairing` | `pilot_candidates/{id}.gmPairings` → editorial review → dish pairings | editorial, after review |
| producer insights | `openData.grapeminds.producer` (founded, hectares, certifications, website) | fact |
| region insights | future region cards | editorial |

Our data rules stay: facts go in as facts with source and date; generated text is labelled; taste scores remain
"estimated" until a person reviews them in the console.

## 4. Licence — settle before storing anything

From GrapeMinds' own pages (checked 10 Oct 2026): the free plan is for development; "commercial usage" is named on
the **Startup** plan; `POST /licence/{wine_id}` buys the right to **store a wine's data permanently** at roughly
€0.38 per wine, metered. Their general terms do not cover API data reuse at all.

So: with the free key we can **evaluate and match** (phases 0–3, cached locally, not published). To publish
GrapeMinds-derived fields in the app we need, in writing from GrapeMinds: (a) that our plan allows commercial display
and (b) whether the per-wine licence is required for cached storage. Budget if yes: 51 wines ≈ €20; 130 wines ≈ €50.

Questions to send GrapeMinds with the first results: provenance of `flavor_profile` (expert / crowd / model),
whether descriptions and pairings are model-generated (their docs say "generated on demand"), attribution wording,
and India coverage gaps we find.

## 5. What to expect

- Indian wines: the catalogue skews European; expect the big producers (Sula, Grover Zampa, Fratelli, York,
  Chandon India, KRSMA) and thin coverage of small ones. `/coverage?country=IN` answers this with one call.
- Spirits and beer: nothing — our 62 non-wine drinks stay on Open Food Facts / Wikidata / BJCP.
- Best value per call: the Indian wine **list** (hundreds of identity rows for under 10 calls), producer insights
  (facts), and flavour profiles for our own 51 wines.

## 6. Tool

`functions/scripts/grapeminds.js` — key from `functions/.env.grapeminds` (gitignored), disk cache under
`functions/scripts/grapeminds-cache/` (gitignored), ledger `grapeminds-ledger.json`, `--dry-run` prints the URL and
counts without calling. Commands: `ping`, `coverage IN`, `regions IN`, `producers IN`, `wines --region <id>`,
`search "<name>"`, `wine <id>`, `producer-insights <id>`, `region-insights <id>`, `match` (our wines → GrapeMinds
ids from cached lists), `report` (what the cache holds, calls used this month).
