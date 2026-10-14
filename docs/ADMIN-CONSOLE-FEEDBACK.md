# Admin Console feedback — extracted from the deep review (9 Oct 2026)

Source: `WineBro/WINEBRO-DEEP-PRODUCT-DATA-UX-REVIEW.md`, section "Admin Console deep review".
Status column is ours (checked against the console as deployed on 9 Oct).

## Verdict (reviewer)
A good internal catalogue editor for a small expert team; not yet a content-operations product. It edits live
documents; WineBro needs candidate → review → release → measure → correct. Access control was out of scope
(Google sign-in + allow-list is now live).

## What already matches the app
Drinks form, dishes form with pairing editor, categories/lists, rules editor with "Try a pairing", scanner
thresholds, photo upload with credits, user/feedback/aggregate views.

## Findings

| ID | Pri | Finding | Our status |
|---|---|---|---|
| AC-01 | P0 | Catalogue edits, imports and deletes go live immediately; no draft/published state, release id or restore for catalogue records (config has history, catalogue does not). | Confirmed. Open. |
| AC-02 | P0 | Import in **merge** mode validates only the id, then batch-merges anything; later batches can fail after earlier ones wrote. | Confirmed. Open. |
| AC-03 | P0 | Server validation is thin: no `sortOrder`, source/evidence, photo licence, pairing score bounds, or check that a pairing targets an existing product. | Confirmed. Open. |
| AC-04 | P0 | "Try a pairing" computes food-fit only; the app also applies palate match, archetype/occasion bonuses, feedback bias and penalties. | Confirmed (by design, labelled "food fit only"). Open. |
| AC-05 | P0 | Every collection is loaded whole into the browser; fine at 111, not at 2,000+. | Confirmed. Open. |
| AC-06 | P0 | Delete is a hard delete with no reference check; journals/wishlists/feedback keep pointing at a missing drink. | Confirmed. Open. |
| AC-07 | P1 | Each config doc goes live on its own; a coordinated change (new food property + rule + dish) can be briefly inconsistent; no staged rollout. | Confirmed. Open. |
| AC-08 | P1 | Editors can add codes the app cannot understand until a release. | **Out of date** for categories/cuisines/food properties/occasions/archetypes (data-driven since 9 Oct). Still true for icon names (registry) and routes. |
| AC-09 | P1 | Home editor manages only legacy tiles + logo, not the decision launcher. | **Partly addressed**: quick-start dishes and retail/reminder flags are editable; launcher copy and state rules are not. |
| AC-10 | P1 | Dashboard shows counts, not content health (missing sources/photos, stale, duplicates, no-match queue, pairing gaps). | Confirmed. Open. |
| AC-11 | P1 | Pilot candidates are raw JSON; no review assignment, evidence, comments, merge or field history. | Confirmed. Open. |
| AC-12 | P1 | Feedback/community pages are read-only tables; a "No" cannot become a tracked correction. | Confirmed. Open. |
| AC-13 | P1 | Uploaded photos carry no rights metadata, crop check or mobile preview. | Confirmed. Open. |
| AC-14 | P1 | `journalScales` is editable but has no effect in the app. | Confirmed. Open (mark read-only). |
| AC-15 | P2 | Navigation is by collection, not by task ("what is broken today?"). | Confirmed. Open. |
| AC-16 | P2 | User detail exposes raw personal subcollections with export; no purpose/reason logging or retention policy. | Confirmed. Open. |
| AC-17 | P2 | No locale/translation workflow for content. | Confirmed. Open. |

## Status after the 10 Oct console release

| ID | What changed |
|---|---|
| AC-01 | Drafts → publish. `drafts_products/dishes/config` hold work in progress; **Publish** (per item or all) writes live, keeps the replaced copy per release (`catalogue_history`, config `history`), writes `releases/{id}`; **Roll back** restores a release. "Publish now" remains for small direct edits. |
| AC-02 | Imports go to drafts; the final merged row is validated in both modes (ids, codes, pairing targets, ranges, duplicates in file); any problem → nothing saved. |
| AC-03 | One validator (`functions/src/admin/schema.ts`) for create, update, import and publish: category/cuisine/property/archetype codes checked against config, pairing targets must exist and not repeat, scores 40–99, sort order required, URLs, text lengths. The editor shows the server's problems while typing. |
| AC-04 | The food-fit-only TypeScript preview is gone. **Preview in WineBro** runs the real app (web build at `/preview/`) in a phone frame; for dish/pairing contexts the app reports its own engine's ranking with live rules and with the draft rules (before/after diff, full score parts). |
| AC-06 | Delete replaced by **Archive/Restore** for drinks and dishes; references (dish pairings, journals, wishlists, feedback) are counted and shown; archived rows are hidden in the app but kept. |
| AC-09 | Home editor: quick-start dishes, retail/reminder switches (launcher copy stays in the app's translations). |
| AC-10 | Dashboard "Needs attention": drinks without photo/ABV/verification/pairing, unknown category codes, dishes with missing or archived pairing targets, dishes with < 2 pairings, archived drinks. |
| AC-13 | Uploads record the uploader; rights fields can be sent with the upload (UI for rights metadata still to do). |
| AC-14 | `journalScales` is marked reference-only and cannot be edited. |
| Preview on a phone | Admins (allow-list → `users/{uid}.isAdmin`) get **Settings → Console → Preview console drafts**; drafts are layered over live data on that phone only, with a banner. |
| Open | AC-05 pagination (111 rows today), AC-07 release bundles across config docs (publish-all covers it operationally), AC-11 candidate review workflow, AC-12 feedback triage, AC-15 task-oriented navigation, AC-16 support/PII split, AC-17 locales. |

## Roles the reviewer expects
Content curator (candidate inbox, evidence, merge), beverage/culinary expert (pairing workbench, golden set,
before/after diff), product/ops lead (release status, content health, queues, rollback), support/data steward
(purpose-scoped cases), growth analyst (decision funnel by release).

## Reviewer's release plan
- **R1 (P0)**: shared schema/validator used by console + functions + CI; import validates the final merged row in
  every mode and stages all-or-nothing; archive instead of hard delete with reference checks; canonical engine in
  the preview with golden fixtures; pagination/filters.
- **R2 (P1)**: candidate/review workflow with sources and licences; content-health dashboard and owned queues;
  pairing QA workbench; asset records with rights; Home controls matching the real Home; deprecate non-live fields.
- **R3 (P1/P2)**: environments, draft releases, approval, scheduled publish, manifest, rollback; analytics by
  release id; split content/support/analytics; locale workflow.

## Definition of done for a publish (reviewer)
Schema + reference checks pass; every claim/photo has source, licence, review status, freshness; no dangling
pairing/alias/category/image/route; engine passes golden set with a visible before/after diff; mobile preview
checked; manifest recorded; post-publish monitoring feeds a corrective queue.
