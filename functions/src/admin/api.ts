/**
 * CF-12: adminApi — JSON API behind the WineBro Console.
 *
 * Served at /api/** through Firebase Hosting (site winebro-console). Uses the
 * Admin SDK, so the mobile app's Firestore rules stay locked.
 *
 * Access: every call needs `Authorization: Bearer <Firebase ID token>` from a
 * Google sign-in whose verified email is in `admin_access/allowlist.emails`.
 * Admins manage that list at /api/access; matching user documents get
 * `isAdmin: true`, which lets the app show drafts in preview mode.
 *
 * Editing model (drafts → publish):
 *   drafts_products/{id}, drafts_dishes/{id}, drafts_config/{doc}
 *     unsaved-to-live work, readable in the app only by admins in preview
 *   publish copies drafts to live, keeps the previous live copy under
 *   catalogue_history/{kind}__{id}/versions/{releaseId}, and writes
 *   releases/{releaseId}; rollback restores a release's previous copies.
 *   Catalogue rows are archived, never hard-deleted.
 *
 * Routes
 *   GET    /api/me
 *   GET    /api/access                            PUT /api/access {emails}
 *   GET    /api/stats
 *   GET    /api/health                            content-health queues
 *   GET    /api/collections/:name                 live rows (+ draft/archived flags)
 *   GET    /api/collections/:name/:id
 *   POST   /api/collections/:name                 {id,...}  ?target=draft|live
 *   PUT    /api/collections/:name/:id             ?target=draft|live (default draft)
 *   POST   /api/collections/:name/:id/archive     POST .../restore
 *   DELETE /api/collections/:name/:id             non-catalogue rows only
 *   POST   /api/collections/:name/validate        {doc} → problems
 *   POST   /api/collections/:name/import          {rows, mode, dryRun} → drafts
 *   GET    /api/drafts                            DELETE /api/drafts/:kind/:id
 *   POST   /api/publish                           {items?: [{kind,id}], note?}
 *   GET    /api/releases                          POST /api/releases/:id/rollback
 *   GET    /api/users/:uid/:sub
 *   GET    /api/config  GET/PUT /api/config/:doc  (?target=draft|live)
 *   GET    /api/config/:doc/history               POST /api/config/:doc/restore/:v
 *   POST   /api/upload                            {path, contentType, dataBase64}
 */
import { randomUUID } from "crypto";
import { onRequest, Request } from "firebase-functions/v2/https";
import type { Response } from "express";
import { DocumentData, FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { getAuth } from "firebase-admin/auth";
import { mergeDocs, RefContext, SCORE_AXES, validateCatalogueDoc } from "./schema";
import * as gm from "./grapeminds";

const BUCKET = "winebro.firebasestorage.app";
const ALLOWLIST_REF = ["admin_access", "allowlist"] as const;

type Kind = "products" | "dishes";
const CATALOGUE = new Set<Kind>(["products", "dishes"]);
const EDITABLE = new Set(["products", "dishes", "pilot_candidates"]);
const READABLE = new Set([...EDITABLE, "users", "community_signals", "pairing_aggregates", "pairing_feedback", "phone_index"]);
const USER_SUBS = new Set(["journal", "wishlist", "gamification", "friends", "fcm_token", "pre_quiz_seed", "cross_category", "aroma_calibration", "events"]);
const CONFIG_DOCS = new Set(["pairingRules", "archetypes", "quiz", "scanner", "gamification", "badges", "categories", "occasions", "journalScales", "aromaWheel", "home", "notifications"]);
/** Documents the app does not read yet; editing them would mislead. */
const CONFIG_READ_ONLY = new Set(["journalScales"]);

class HttpError extends Error {
  constructor(public status: number, message: string, public details?: unknown) {
    super(message);
  }
}

function plain(value: unknown): unknown {
  if (value instanceof Timestamp) return value.toDate().toISOString();
  if (Array.isArray(value)) return value.map(plain);
  if (value && typeof value === "object") {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) out[k] = plain(v);
    return out;
  }
  return value;
}

function isRecord(v: unknown): v is Record<string, unknown> {
  return !!v && typeof v === "object" && !Array.isArray(v);
}

async function readBody(req: Request): Promise<Record<string, unknown>> {
  const b = req.body;
  if (isRecord(b)) return b;
  if (typeof b === "string" && b) {
    const parsed = JSON.parse(b);
    if (isRecord(parsed)) return parsed;
  }
  throw new HttpError(400, "JSON object body required");
}

type Caller = { email: string; name: string; uid: string };
type Ctx = { db: FirebaseFirestore.Firestore; req: Request; res: Response; caller: Caller };

// ─── Access ──────────────────────────────────────────────────────

async function allowlist(db: FirebaseFirestore.Firestore): Promise<string[]> {
  const snap = await db.collection(ALLOWLIST_REF[0]).doc(ALLOWLIST_REF[1]).get();
  const emails = snap.get("emails");
  return Array.isArray(emails) ? emails.map((e) => String(e).trim().toLowerCase()).filter(Boolean) : [];
}

async function authenticate(req: Request): Promise<Caller> {
  const header = req.get("Authorization") ?? "";
  const token = header.startsWith("Bearer ") ? header.slice(7).trim() : "";
  if (!token) throw new HttpError(401, "sign in required");
  let decoded;
  try {
    decoded = await getAuth().verifyIdToken(token, true);
  } catch {
    throw new HttpError(401, "sign-in expired; please sign in again");
  }
  const email = (decoded.email ?? "").toLowerCase();
  if (!email || decoded.email_verified !== true) throw new HttpError(403, "a verified Google email is required");
  return { email, name: String(decoded.name ?? email), uid: decoded.uid };
}

/** Mirrors the allow-list onto users/{uid}.isAdmin so the app can gate preview mode. */
export async function syncAdminFlags(db: FirebaseFirestore.Firestore, emails: string[], previous: string[]) {
  const auth = getAuth();
  const apply = async (email: string, isAdmin: boolean) => {
    try {
      const u = await auth.getUserByEmail(email);
      await db.collection("users").doc(u.uid).set({ isAdmin }, { merge: true });
    } catch {
      /* no account with that email yet; the flag is set when they sign in and the list is saved again */
    }
  };
  await Promise.all([
    ...emails.map((e) => apply(e, true)),
    ...previous.filter((e) => !emails.includes(e)).map((e) => apply(e, false)),
  ]);
}

async function accessGet({ db }: Ctx) {
  const snap = await db.collection(ALLOWLIST_REF[0]).doc(ALLOWLIST_REF[1]).get();
  return { emails: await allowlist(db), updatedAt: plain(snap.get("updatedAt")), updatedBy: snap.get("updatedBy") ?? "" };
}

async function accessPut(ctx: Ctx) {
  const body = await readBody(ctx.req);
  const raw = Array.isArray(body.emails) ? body.emails : null;
  if (!raw) throw new HttpError(400, "emails must be a list");
  const emails = [...new Set(raw.map((e) => String(e).trim().toLowerCase()).filter(Boolean))];
  const bad = emails.filter((e) => !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(e));
  if (bad.length) throw new HttpError(422, `not an email: ${bad.join(", ")}`);
  if (!emails.includes(ctx.caller.email)) throw new HttpError(422, "you cannot remove your own access");
  const previous = await allowlist(ctx.db);
  await ctx.db.collection(ALLOWLIST_REF[0]).doc(ALLOWLIST_REF[1]).set({ emails, updatedAt: FieldValue.serverTimestamp(), updatedBy: ctx.caller.email });
  await syncAdminFlags(ctx.db, emails, previous);
  return accessGet(ctx);
}

// ─── Reference data for validation ───────────────────────────────

async function refContext(db: FirebaseFirestore.Firestore, includeDrafts = true): Promise<RefContext> {
  const [products, draftProducts, categories, archetypes, draftCategories, draftArchetypes] = await Promise.all([
    db.collection("products").select().get(),
    includeDrafts ? db.collection("drafts_products").select().get() : null,
    db.collection("config").doc("categories").get(),
    db.collection("config").doc("archetypes").get(),
    includeDrafts ? db.collection("drafts_config").doc("categories").get() : null,
    includeDrafts ? db.collection("drafts_config").doc("archetypes").get() : null,
  ]);
  const codes = (snap: FirebaseFirestore.DocumentSnapshot | null, key: string) =>
    ((snap?.get(key) as { code?: string }[] | undefined) ?? []).map((x) => String(x.code));
  const cats = draftCategories?.exists ? draftCategories : categories;
  const arch = draftArchetypes?.exists ? draftArchetypes : archetypes;
  return {
    productIds: new Set([...products.docs.map((d) => d.id), ...(draftProducts?.docs.map((d) => d.id) ?? [])]),
    drinkCategories: new Set(codes(cats, "drinks")),
    cuisines: new Set(codes(cats, "cuisines")),
    foodProperties: new Set(codes(cats, "foodProperties")),
    archetypes: new Set(codes(arch, "items")),
  };
}

function stripMeta(doc: Record<string, unknown>) {
  const { updatedAt, openDataUpdatedAt, createdAt, updatedBy, _draft, ...rest } = doc;
  void updatedAt; void openDataUpdatedAt; void createdAt; void updatedBy; void _draft;
  return rest;
}

// ─── Stats & health ──────────────────────────────────────────────

async function stats({ db }: Ctx) {
  const count = async (q: FirebaseFirestore.Query) => (await q.count().get()).data().count;
  const products = db.collection("products");
  const [drinks, dishes, verified, archived, users, journal, wishlist, signals, feedback, aggregates, drafts, configSnap] = await Promise.all([
    count(products), count(db.collection("dishes")), count(products.where("verified", "==", true)),
    count(products.where("archived", "==", true)), count(db.collection("users")),
    count(db.collectionGroup("journal")), count(db.collectionGroup("wishlist")),
    count(db.collection("community_signals")), count(db.collection("pairing_feedback")), count(db.collection("pairing_aggregates")),
    Promise.all([count(db.collection("drafts_products")), count(db.collection("drafts_dishes")), count(db.collection("drafts_config"))]).then((a) => a[0] + a[1] + a[2]),
    db.collection("config").get(),
  ]);
  return {
    drinks, dishes, verified, archived, users, journalEntries: journal, wishlistAdds: wishlist,
    communitySignals: signals, pairingFeedback: feedback, pairingAggregates: aggregates, pendingDrafts: drafts,
    config: configSnap.docs.map((d) => ({ id: d.id, version: d.get("version") ?? 0, source: d.get("source") ?? "", updatedAt: plain(d.get("updatedAt")) })),
  };
}

/** Content-health queues computed over the live catalogue. */
async function health({ db }: Ctx) {
  const [p, d, refs] = await Promise.all([db.collection("products").get(), db.collection("dishes").get(), refContext(db, false)]);
  const products: DocumentData[] = p.docs.map((x) => ({ id: x.id, ...x.data() }));
  const dishes: DocumentData[] = d.docs.map((x) => ({ id: x.id, ...x.data() }));
  const live = (x: DocumentData) => x.archived !== true;
  const od = (x: DocumentData, k: string) => (x.openData ?? {})[k] ?? {};
  const photo = (x: DocumentData) => x.imageUrl || od(x, "bottlePhoto").imageUrl || od(x, "openFoodFacts").imageUrl;
  const curatedFor = new Set(dishes.flatMap((x) => ((x.pairings as { productId: string }[]) ?? []).map((e) => e.productId)));
  const queue = (title: string, kind: string, items: DocumentData[], hint: string) => ({ title, kind, hint, count: items.length, ids: items.slice(0, 200).map((x) => ({ id: x.id, name: x.name })) });
  return {
    queues: [
      queue("Drinks without a photo", "products", products.filter((x) => live(x) && !photo(x)), "Upload a photo or link an open-licence one"),
      queue("Drinks without ABV", "products", products.filter((x) => live(x) && (x.abv === undefined || x.abv === null)), "Check the label or producer page"),
      queue("Drinks not yet verified by a person", "products", products.filter((x) => live(x) && x.verified !== true), "Review the taste scores and tick Verified"),
      queue("Drinks with no hand-written pairing", "products", products.filter((x) => live(x) && !curatedFor.has(x.id)), "Add the drink to at least one dish's pairings"),
      queue("Drinks with an unknown category code", "products", products.filter((x) => live(x) && !refs.drinkCategories.has(String(x.category))), "Fix the category or add the code under Rules → Categories"),
      queue("Dishes with a pairing to a missing or archived drink", "dishes", dishes.filter((x) => live(x) && ((x.pairings as { productId: string }[]) ?? []).some((e) => !products.some((pp) => pp.id === e.productId && live(pp)))), "Edit the dish's pairings"),
      queue("Dishes without a photo", "dishes", dishes.filter((x) => live(x) && !x.imageUrl && !od(x, "photo").imageUrl), "Upload a photo"),
      queue("Dishes with fewer than 2 pairings", "dishes", dishes.filter((x) => live(x) && (((x.pairings as unknown[]) ?? []).length < 2)), "Add hand-written pairings so results are not rules-only"),
      queue("Archived drinks", "products", products.filter((x) => !live(x)), "Hidden from the app; restore if needed"),
    ],
  };
}

// ─── Catalogue reads ─────────────────────────────────────────────

async function listCollection({ db }: Ctx, name: string) {
  if (!READABLE.has(name)) throw new HttpError(404, `unknown collection ${name}`);
  const snap = await db.collection(name).get();
  const rows = snap.docs.map((d) => ({ ...(plain(d.data()) as object), id: d.id }) as Record<string, unknown>);
  if (CATALOGUE.has(name as Kind)) {
    const drafts = await db.collection(`drafts_${name}`).get();
    const draftIds = new Set(drafts.docs.map((d) => d.id));
    for (const r of rows) r.hasDraft = draftIds.has(String(r.id));
    for (const d of drafts.docs) {
      if (!rows.some((r) => r.id === d.id)) rows.push({ ...(plain(d.data()) as object), id: d.id, hasDraft: true, draftOnly: true });
    }
  }
  return rows;
}

async function getDoc({ db }: Ctx, name: string, id: string) {
  if (!READABLE.has(name)) throw new HttpError(404, `unknown collection ${name}`);
  const d = await db.collection(name).doc(id).get();
  const draft = CATALOGUE.has(name as Kind) ? await db.collection(`drafts_${name}`).doc(id).get() : null;
  if (!d.exists && !draft?.exists) throw new HttpError(404, "not found");
  const live = d.exists ? { ...(plain(d.data()) as object), id: d.id } : null;
  return { ...(live ?? {}), id, live, draft: draft?.exists ? { ...(plain(draft.data()) as object), id } : null };
}

// ─── Catalogue writes ────────────────────────────────────────────

function stampReview(data: DocumentData, body: Record<string, unknown>, existing: FirebaseFirestore.DocumentSnapshot | null, caller: Caller) {
  const scoresChanged = SCORE_AXES.some((a) => existing?.exists && existing.get(a) !== body[a]);
  if (scoresChanged || (!existing?.exists && !isRecord(body.estimate))) {
    const estimate = isRecord(body.estimate) ? { ...body.estimate } : {};
    estimate.reviewedBy = caller.email;
    estimate.reviewedAt = new Date().toISOString();
    if (!estimate.label) estimate.label = "Reviewed by WineBro";
    data.estimate = estimate;
    data.provenance = "admin-reviewed";
  }
  if (body.verified === true && existing?.get("verified") !== true) {
    data.verifiedBy = caller.email;
    data.verifiedAt = new Date().toISOString();
  }
}

async function validateDoc(ctx: Ctx, name: string) {
  if (!CATALOGUE.has(name as Kind)) throw new HttpError(404, `no validation for ${name}`);
  const body = await readBody(ctx.req);
  const doc = stripMeta(isRecord(body.doc) ? body.doc : body);
  const problems = validateCatalogueDoc(name as Kind, doc, await refContext(ctx.db));
  return { problems, doc };
}

async function writeDoc(ctx: Ctx, name: string, id: string, create: boolean) {
  if (!EDITABLE.has(name)) throw new HttpError(403, `${name} is not editable`);
  const target = ctx.req.query.target === "live" ? "live" : "draft";
  const body = stripMeta(await readBody(ctx.req));
  body.id = id;
  const liveRef = ctx.db.collection(name).doc(id);
  const existing = await liveRef.get();
  if (create && existing.exists) throw new HttpError(409, `${id} already exists`);
  if (!create && !existing.exists && !CATALOGUE.has(name as Kind)) throw new HttpError(404, "not found");

  if (!CATALOGUE.has(name as Kind)) {
    // pilot_candidates: working data, written directly
    await liveRef.set({ ...body, updatedAt: FieldValue.serverTimestamp(), updatedBy: ctx.caller.email }, { merge: !create });
    return getDoc(ctx, name, id);
  }

  const problems = validateCatalogueDoc(name as Kind, body, await refContext(ctx.db));
  if (problems.length) throw new HttpError(422, problems.join("; "), { problems });

  const data: DocumentData = {
    ...body,
    source: body.source ?? existing.get("source") ?? "admin",
    provenance: body.provenance ?? existing.get("provenance") ?? "admin-entered",
  };
  if (name === "products") stampReview(data, body, existing.exists ? existing : null, ctx.caller);

  if (target === "draft") {
    await ctx.db.collection(`drafts_${name}`).doc(id).set({
      ...data,
      _draft: { kind: name, id, savedBy: ctx.caller.email, savedAt: FieldValue.serverTimestamp(), baseUpdatedAt: existing.get("updatedAt") ?? null, isNew: !existing.exists },
    });
    return getDoc(ctx, name, id);
  }
  // publish straight away, keeping history
  await publishItems(ctx, [{ kind: name as Kind, id, data }], "direct save");
  return getDoc(ctx, name, id);
}

async function setArchived(ctx: Ctx, name: string, id: string, archived: boolean) {
  if (!CATALOGUE.has(name as Kind)) throw new HttpError(404, `${name} cannot be archived`);
  const ref = ctx.db.collection(name).doc(id);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpError(404, "not found");
  const refsReport = archived ? await referencesTo(ctx.db, name as Kind, id) : null;
  const data = { ...snap.data(), archived, archivedAt: archived ? new Date().toISOString() : null, archivedBy: archived ? ctx.caller.email : null };
  await publishItems(ctx, [{ kind: name as Kind, id, data }], archived ? "archive" : "restore");
  return { id, archived, references: refsReport };
}

/** Where a drink or dish is still referred to; used to warn before archiving. */
async function referencesTo(db: FirebaseFirestore.Firestore, kind: Kind, id: string) {
  const count = async (q: FirebaseFirestore.Query) => (await q.count().get()).data().count;
  if (kind === "products") {
    const dishes = await db.collection("dishes").get();
    const inPairings = dishes.docs.filter((d) => ((d.get("pairings") as { productId: string }[]) ?? []).some((p) => p.productId === id)).map((d) => d.id);
    const [journal, wishlist, feedback] = await Promise.all([
      count(db.collectionGroup("journal").where("productId", "==", id)),
      count(db.collectionGroup("wishlist").where("productId", "==", id)),
      count(db.collection("pairing_feedback").where("productId", "==", id)),
    ]);
    return { dishesWithPairing: inPairings, journalEntries: journal, wishlistEntries: wishlist, feedbackRows: feedback };
  }
  return { journalEntries: 0 };
}

async function deleteDoc({ db }: Ctx, name: string, id: string) {
  if (!READABLE.has(name)) throw new HttpError(404, `unknown collection ${name}`);
  if (CATALOGUE.has(name as Kind)) throw new HttpError(422, "drinks and dishes are archived, not deleted (use /archive)");
  if (name === "community_signals" || name === "pairing_aggregates") throw new HttpError(403, `${name} rows are computed; they cannot be deleted here`);
  const ref = db.collection(name).doc(id);
  if (!(await ref.get()).exists) throw new HttpError(404, "not found");
  if (name === "users") await db.recursiveDelete(ref);
  else await ref.delete();
  return { deleted: id };
}

// ─── Import (to drafts) ──────────────────────────────────────────

async function importRows(ctx: Ctx, name: string) {
  if (!CATALOGUE.has(name as Kind)) throw new HttpError(403, `${name} cannot be imported`);
  const kind = name as Kind;
  const body = await readBody(ctx.req);
  const rows = Array.isArray(body.rows) ? body.rows : null;
  if (!rows) throw new HttpError(400, "rows must be a list");
  const mode = body.mode === "replace" ? "replace" : "merge";
  const dryRun = body.dryRun === true;

  const [liveSnap, draftSnap] = await Promise.all([ctx.db.collection(name).get(), ctx.db.collection(`drafts_${name}`).get()]);
  const live = new Map(liveSnap.docs.map((d) => [d.id, d.data()]));
  const drafts = new Map(draftSnap.docs.map((d) => [d.id, stripMeta(d.data())]));
  const refs = await refContext(ctx.db);

  const errors: { row: number; id: string; problems: string[] }[] = [];
  const staged: { id: string; data: Record<string, unknown>; isNew: boolean }[] = [];
  const seen = new Set<string>();
  rows.forEach((raw, i) => {
    if (!isRecord(raw)) { errors.push({ row: i + 1, id: "", problems: ["row is not an object"] }); return; }
    const patch = stripMeta(raw);
    const id = typeof patch.id === "string" ? patch.id.trim() : "";
    if (!id) { errors.push({ row: i + 1, id: "", problems: ["id is required"] }); return; }
    if (seen.has(id)) { errors.push({ row: i + 1, id, problems: ["duplicate id in this file"] }); return; }
    seen.add(id);
    const base = drafts.get(id) ?? live.get(id);
    const merged = mode === "replace" || !base ? { ...patch, id } : mergeDocs(stripMeta(base), { ...patch, id });
    // new drinks in this file may be referenced by dishes in the same file
    if (kind === "products") refs.productIds.add(id);
    const problems = validateCatalogueDoc(kind, merged, refs);
    if (problems.length) { errors.push({ row: i + 1, id, problems }); return; }
    staged.push({ id, data: merged, isNew: !live.has(id) });
  });

  const report = { rows: rows.length, valid: staged.length, errors, mode, writtenToDrafts: 0, created: 0, updated: 0 };
  if (dryRun || errors.length) return { ...report, wouldWrite: errors.length ? 0 : staged.length, blocked: errors.length > 0 };

  for (let i = 0; i < staged.length; i += 400) {
    const batch = ctx.db.batch();
    for (const s of staged.slice(i, i + 400)) {
      const existing = live.get(s.id);
      const data: DocumentData = {
        ...s.data,
        source: s.data.source ?? existing?.source ?? "admin-import",
        provenance: s.data.provenance ?? existing?.provenance ?? "admin-entered",
        _draft: { kind, id: s.id, savedBy: ctx.caller.email, savedAt: FieldValue.serverTimestamp(), baseUpdatedAt: existing?.updatedAt ?? null, isNew: s.isNew, via: "import" },
      };
      batch.set(ctx.db.collection(`drafts_${name}`).doc(s.id), data);
      report.writtenToDrafts++;
      if (s.isNew) report.created++; else report.updated++;
    }
    await batch.commit();
  }
  return report;
}

// ─── Drafts, publish, releases ───────────────────────────────────

async function draftsList({ db }: Ctx) {
  const [p, d, c] = await Promise.all([db.collection("drafts_products").get(), db.collection("drafts_dishes").get(), db.collection("drafts_config").get()]);
  const row = (kind: string) => (x: FirebaseFirestore.QueryDocumentSnapshot) => ({ kind, id: x.id, name: x.get("name") ?? x.id, meta: plain(x.get("_draft")) });
  return { items: [...p.docs.map(row("products")), ...d.docs.map(row("dishes")), ...c.docs.map(row("config"))] };
}

async function draftDiscard({ db }: Ctx, kind: string, id: string) {
  if (!CATALOGUE.has(kind as Kind) && kind !== "config") throw new HttpError(404, `unknown draft kind ${kind}`);
  await db.collection(`drafts_${kind}`).doc(id).delete();
  return { discarded: `${kind}/${id}` };
}

type PublishItem = { kind: Kind; id: string; data: DocumentData };

/** Writes items live, archiving the previous copies under one release id. */
async function publishItems(ctx: Ctx, items: PublishItem[], note: string, configDocs: string[] = []) {
  const db = ctx.db;
  const releaseId = `${new Date().toISOString().replace(/[-:.TZ]/g, "").slice(0, 14)}-${randomUUID().slice(0, 6)}`;
  const manifest: Record<string, unknown>[] = [];
  for (const it of items) {
    try {
      await gm.assertPublishable(db, it.kind, it.data as Record<string, unknown>);
    } catch (e) {
      if (e instanceof gm.GmError) throw new HttpError(e.status, e.message, e.details);
      throw e;
    }
  }
  for (let i = 0; i < items.length; i += 200) {
    const batch = db.batch();
    for (const it of items.slice(i, i + 200)) {
      const liveRef = db.collection(it.kind).doc(it.id);
      const prev = await liveRef.get();
      if (prev.exists) {
        batch.set(db.collection("catalogue_history").doc(`${it.kind}__${it.id}`).collection("versions").doc(releaseId), { ...prev.data(), _archivedAt: FieldValue.serverTimestamp(), _releaseId: releaseId });
      }
      const { _draft, ...content } = it.data;
      void _draft;
      batch.set(liveRef, { ...content, id: it.id, updatedAt: FieldValue.serverTimestamp(), updatedBy: ctx.caller.email, releaseId, ...(prev.exists ? {} : { createdAt: FieldValue.serverTimestamp() }) });
      batch.delete(db.collection(`drafts_${it.kind}`).doc(it.id));
      manifest.push({ kind: it.kind, id: it.id, name: content.name ?? it.id, hadPrevious: prev.exists, archived: content.archived === true });
    }
    await batch.commit();
  }
  for (const doc of configDocs) {
    const draft = await db.collection("drafts_config").doc(doc).get();
    if (!draft.exists) continue;
    const { _draft, ...content } = draft.data() as Record<string, unknown>;
    void _draft;
    const version = await writeConfigLive(ctx, doc, content, undefined, releaseId);
    await draft.ref.delete();
    manifest.push({ kind: "config", id: doc, version });
  }
  if (manifest.length) {
    await db.collection("releases").doc(releaseId).set({ id: releaseId, note, by: ctx.caller.email, at: FieldValue.serverTimestamp(), items: manifest, counts: { products: manifest.filter((m) => m.kind === "products").length, dishes: manifest.filter((m) => m.kind === "dishes").length, config: manifest.filter((m) => m.kind === "config").length } });
  }
  return { releaseId, items: manifest };
}

async function publish(ctx: Ctx) {
  const body = await readBody(ctx.req);
  const wanted = Array.isArray(body.items) ? (body.items as { kind: string; id: string }[]) : null;
  const note = typeof body.note === "string" ? body.note.slice(0, 300) : "";
  const all = (await draftsList(ctx)).items;
  const selected = wanted ? all.filter((d) => wanted.some((w) => w.kind === d.kind && w.id === d.id)) : all;
  if (!selected.length) throw new HttpError(422, "nothing to publish");

  // Validate every catalogue draft against the final reference set before anything goes live.
  const refs = await refContext(ctx.db);
  const problems: { kind: string; id: string; problems: string[] }[] = [];
  const items: PublishItem[] = [];
  for (const s of selected.filter((x) => x.kind !== "config")) {
    const snap = await ctx.db.collection(`drafts_${s.kind}`).doc(s.id).get();
    if (!snap.exists) continue;
    const data = stripMeta(snap.data() as Record<string, unknown>);
    const p = validateCatalogueDoc(s.kind as Kind, data, refs);
    if (p.length) problems.push({ kind: s.kind, id: s.id, problems: p });
    else items.push({ kind: s.kind as Kind, id: s.id, data });
  }
  if (problems.length) throw new HttpError(422, "some drafts have problems; nothing was published", { problems });
  const result = await publishItems(ctx, items, note || "console publish", selected.filter((x) => x.kind === "config").map((x) => x.id));
  return result;
}

async function releasesList({ db }: Ctx) {
  const snap = await db.collection("releases").orderBy("at", "desc").limit(100).get();
  return snap.docs.map((d) => ({ ...(plain(d.data()) as object), id: d.id }));
}

/** Restores every catalogue item of a release to the copy it replaced (as a new release). */
async function rollback(ctx: Ctx, releaseId: string) {
  const rel = await ctx.db.collection("releases").doc(releaseId).get();
  if (!rel.exists) throw new HttpError(404, "release not found");
  const items: PublishItem[] = [];
  const skipped: string[] = [];
  for (const m of (rel.get("items") as { kind: string; id: string; hadPrevious?: boolean }[]) ?? []) {
    if (m.kind === "config") {
      const hist = await ctx.db.collection("config").doc(m.id).collection("history").where("_releaseId", "==", releaseId).limit(1).get();
      if (hist.empty) { skipped.push(`config/${m.id}`); continue; }
      const { version: _v, source: _s, updatedAt: _u, archivedAt: _a, _releaseId, ...content } = hist.docs[0].data();
      void _v; void _s; void _u; void _a; void _releaseId;
      await writeConfigLive(ctx, m.id, content, undefined, `rollback-${releaseId}`);
      continue;
    }
    const prev = await ctx.db.collection("catalogue_history").doc(`${m.kind}__${m.id}`).collection("versions").doc(releaseId).get();
    if (!prev.exists) {
      if (m.hadPrevious === false) items.push({ kind: m.kind as Kind, id: m.id, data: { ...(await ctx.db.collection(m.kind).doc(m.id).get()).data(), archived: true, archivedAt: new Date().toISOString(), archivedBy: ctx.caller.email } });
      else skipped.push(`${m.kind}/${m.id}`);
      continue;
    }
    const { _archivedAt, _releaseId, ...data } = prev.data() as Record<string, unknown>;
    void _archivedAt; void _releaseId;
    items.push({ kind: m.kind as Kind, id: m.id, data });
  }
  const result = items.length ? await publishItems(ctx, items, `rollback of ${releaseId}`) : { releaseId: null, items: [] };
  return { ...result, skipped };
}

// ─── Users ───────────────────────────────────────────────────────

async function userSub({ db }: Ctx, uid: string, sub: string) {
  if (!USER_SUBS.has(sub)) throw new HttpError(404, `unknown subcollection ${sub}`);
  const snap = await db.collection("users").doc(uid).collection(sub).get();
  return snap.docs.map((d) => ({ ...(plain(d.data()) as object), id: d.id }));
}

// ─── Config ──────────────────────────────────────────────────────

async function configAll({ db }: Ctx) {
  const [live, drafts] = await Promise.all([db.collection("config").get(), db.collection("drafts_config").get()]);
  const draftIds = new Set(drafts.docs.map((d) => d.id));
  return live.docs.map((d) => ({ ...(plain(d.data()) as object), id: d.id, hasDraft: draftIds.has(d.id), readOnly: CONFIG_READ_ONLY.has(d.id) }));
}

async function configGet({ db }: Ctx, doc: string) {
  if (!CONFIG_DOCS.has(doc)) throw new HttpError(404, `unknown config ${doc}`);
  const [d, draft] = await Promise.all([db.collection("config").doc(doc).get(), db.collection("drafts_config").doc(doc).get()]);
  if (!d.exists) throw new HttpError(404, "not found");
  return { ...(plain(d.data()) as object), id: d.id, readOnly: CONFIG_READ_ONLY.has(doc), draft: draft.exists ? { ...(plain(draft.data()) as object), id: doc } : null };
}

async function writeConfigLive(ctx: Ctx, doc: string, content: Record<string, unknown>, expectedVersion: number | undefined, releaseId: string) {
  const ref = ctx.db.collection("config").doc(doc);
  let newVersion = 0;
  await ctx.db.runTransaction(async (tx) => {
    const current = await tx.get(ref);
    const currentVersion = current.exists ? ((current.get("version") as number) ?? 0) : 0;
    if (expectedVersion !== undefined && expectedVersion !== currentVersion) throw new HttpError(409, `config/${doc} changed meanwhile (v${currentVersion}); reload and retry`);
    if (current.exists) tx.set(ref.collection("history").doc(String(currentVersion)), { ...current.data(), archivedAt: FieldValue.serverTimestamp(), _releaseId: releaseId });
    newVersion = currentVersion + 1;
    tx.set(ref, { ...content, version: newVersion, source: "admin", updatedAt: FieldValue.serverTimestamp(), updatedBy: ctx.caller.email, releaseId });
  });
  return newVersion;
}

async function configPut(ctx: Ctx, doc: string) {
  if (!CONFIG_DOCS.has(doc)) throw new HttpError(404, `unknown config ${doc}`);
  if (CONFIG_READ_ONLY.has(doc)) throw new HttpError(422, `config/${doc} is reference-only; the app does not read it yet`);
  const target = ctx.req.query.target === "live" ? "live" : "draft";
  const body = await readBody(ctx.req);
  const { version, source: _s, updatedAt: _u, id: _i, draft: _d, readOnly: _r, hasDraft: _h, _draft, ...content } = body;
  void _s; void _u; void _i; void _d; void _r; void _h; void _draft;
  if (Object.keys(content).length === 0) throw new HttpError(422, "empty content");
  if (target === "draft") {
    await ctx.db.collection("drafts_config").doc(doc).set({ ...content, _draft: { kind: "config", id: doc, savedBy: ctx.caller.email, savedAt: FieldValue.serverTimestamp(), baseVersion: typeof version === "number" ? version : null } });
    return configGet(ctx, doc);
  }
  await writeConfigLive(ctx, doc, content, typeof version === "number" ? version : undefined, "direct save");
  await ctx.db.collection("drafts_config").doc(doc).delete();
  return configGet(ctx, doc);
}

async function configHistory({ db }: Ctx, doc: string) {
  if (!CONFIG_DOCS.has(doc)) throw new HttpError(404, `unknown config ${doc}`);
  const snap = await db.collection("config").doc(doc).collection("history").get();
  return snap.docs.map((d) => ({ ...(plain(d.data()) as object), id: d.id })).sort((a, b) => Number(b.id) - Number(a.id));
}

async function configRestore(ctx: Ctx, doc: string, version: string) {
  if (!CONFIG_DOCS.has(doc)) throw new HttpError(404, `unknown config ${doc}`);
  const old = await ctx.db.collection("config").doc(doc).collection("history").doc(version).get();
  if (!old.exists) throw new HttpError(404, `no version ${version}`);
  const { version: _v, source: _s, updatedAt: _u, archivedAt: _a, _releaseId, updatedBy: _b, releaseId: _r, ...content } = old.data() as Record<string, unknown>;
  void _v; void _s; void _u; void _a; void _releaseId; void _b; void _r;
  await writeConfigLive(ctx, doc, content, undefined, `restore-v${version}`);
  return configGet(ctx, doc);
}

// ─── Upload ──────────────────────────────────────────────────────

async function upload(ctx: Ctx) {
  const body = await readBody(ctx.req);
  const path = typeof body.path === "string" ? body.path.replace(/^\/+/, "") : "";
  const contentType = typeof body.contentType === "string" ? body.contentType : "";
  const data = typeof body.dataBase64 === "string" ? body.dataBase64 : "";
  if (!/^catalogue\/(products|dishes|home|categories)\/[A-Za-z0-9._/-]+$/.test(path)) throw new HttpError(422, "path must be catalogue/<products|dishes|home|categories>/<file>");
  if (!/^image\/(jpeg|png|webp)$/.test(contentType)) throw new HttpError(422, "image/jpeg, png or webp only");
  const buffer = Buffer.from(data, "base64");
  if (buffer.length === 0) throw new HttpError(422, "empty file");
  if (buffer.length > 5 * 1024 * 1024) throw new HttpError(413, "image larger than 5 MB");
  const token = randomUUID();
  const file = getStorage().bucket(BUCKET).file(path);
  const rights = isRecord(body.rights) ? body.rights : {};
  await file.save(buffer, { contentType, metadata: { metadata: { firebaseStorageDownloadTokens: token, uploadedBy: ctx.caller.email, ...Object.fromEntries(Object.entries(rights).map(([k, v]) => [k, String(v)])) }, cacheControl: "public, max-age=31536000" } });
  const url = `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
  return { path, url, bytes: buffer.length };
}

// ─── Data Cellar: GrapeMinds ─────────────────────────────────────

async function grapemindsRoute(ctx: Ctx, sub: string | undefined, m: string) {
  try {
    const body = m === "POST" || m === "PUT" ? await readBody(ctx.req) : {};
    switch (`${m} ${sub ?? ""}`) {
      case "GET status": return await gm.status(ctx.db);
      case "GET wines": return await gm.listWines(ctx.db);
      case "GET matches": return await gm.matches(ctx.db);
      case "POST estimate": return await gm.estimate(ctx.db, body.action as gm.Action);
      case "POST run": {
        if (body.confirm !== true) throw new HttpError(422, "confirm the estimate first");
        return await gm.run(ctx.db, ctx.caller.email, body.action as gm.Action);
      }
      case "POST map": return await gm.applyMapping(ctx.db, ctx.caller.email, body);
      case "POST create": return await gm.createFromGrapeminds(ctx.db, ctx.caller.email, body);
      case "PUT terms": return await gm.setTerms(ctx.db, ctx.caller.email, body);
      case "PUT budget": return await gm.setBudget(ctx.db, body);
      default: throw new HttpError(404, `no route ${m} /api/sources/grapeminds/${sub ?? ""}`);
    }
  } catch (e) {
    if (e instanceof gm.GmError) throw new HttpError(e.status, e.message, e.details);
    throw e;
  }
}

// ─── Router ──────────────────────────────────────────────────────

export const adminApi = onRequest(
  { region: "asia-south1", memory: "512MiB", timeoutSeconds: 300, maxInstances: 3, secrets: [gm.GRAPEMINDS_KEY] },
  async (req, res) => {
    const db = getFirestore();
    const parts = req.path.replace(/^\/api\/?/, "").split("/").filter(Boolean).map(decodeURIComponent);
    const m = req.method;
    res.set("Cache-Control", "no-store");
    try {
      const caller = await authenticate(req);
      const allowed = (await allowlist(db)).includes(caller.email);
      if (parts[0] === "me" && m === "GET") {
        if (allowed) await db.collection("users").doc(caller.uid).set({ isAdmin: true }, { merge: true });
        res.status(200).json({ email: caller.email, name: caller.name, allowed });
        return;
      }
      if (!allowed) throw new HttpError(403, `${caller.email} is not on the admin list`);
      const ctx: Ctx = { db, req, res, caller };
      const [a, b, c, d] = parts;
      let result: unknown;
      if (a === "access" && m === "GET") result = await accessGet(ctx);
      else if (a === "access" && m === "PUT") result = await accessPut(ctx);
      else if (a === "stats" && m === "GET") result = await stats(ctx);
      else if (a === "health" && m === "GET") result = await health(ctx);
      else if (a === "collections" && parts.length === 2 && m === "GET") result = await listCollection(ctx, b);
      else if (a === "collections" && parts.length === 2 && m === "POST") {
        const body = await readBody(req);
        if (typeof body.id !== "string" || !body.id) throw new HttpError(422, "id is required");
        req.body = body;
        result = await writeDoc(ctx, b, body.id, true);
      } else if (a === "collections" && c === "import" && m === "POST") result = await importRows(ctx, b);
      else if (a === "collections" && c === "validate" && m === "POST") result = await validateDoc(ctx, b);
      else if (a === "collections" && parts.length === 3 && m === "GET") result = await getDoc(ctx, b, c);
      else if (a === "collections" && parts.length === 3 && m === "PUT") result = await writeDoc(ctx, b, c, false);
      else if (a === "collections" && parts.length === 3 && m === "DELETE") result = await deleteDoc(ctx, b, c);
      else if (a === "collections" && d === "archive" && m === "POST") result = await setArchived(ctx, b, c, true);
      else if (a === "collections" && d === "restore" && m === "POST") result = await setArchived(ctx, b, c, false);
      else if (a === "drafts" && parts.length === 1 && m === "GET") result = await draftsList(ctx);
      else if (a === "drafts" && parts.length === 3 && m === "DELETE") result = await draftDiscard(ctx, b, c);
      else if (a === "publish" && m === "POST") result = await publish(ctx);
      else if (a === "releases" && parts.length === 1 && m === "GET") result = await releasesList(ctx);
      else if (a === "releases" && c === "rollback" && m === "POST") result = await rollback(ctx, b);
      else if (a === "users" && parts.length === 3 && m === "GET") result = await userSub(ctx, b, c);
      else if (a === "config" && parts.length === 1 && m === "GET") result = await configAll(ctx);
      else if (a === "config" && parts.length === 2 && m === "GET") result = await configGet(ctx, b);
      else if (a === "config" && parts.length === 2 && m === "PUT") result = await configPut(ctx, b);
      else if (a === "config" && c === "history" && m === "GET") result = await configHistory(ctx, b);
      else if (a === "config" && c === "restore" && m === "POST") result = await configRestore(ctx, b, d);
      else if (a === "upload" && m === "POST") result = await upload(ctx);
      else if (a === "sources" && parts.length === 1 && m === "GET") result = await gm.sourcesOverview(db);
      else if (a === "sources" && b === "grapeminds") result = await grapemindsRoute(ctx, c, m);
      else throw new HttpError(404, `no route ${m} /api/${parts.join("/")}`);
      res.status(200).json(result);
    } catch (e) {
      const status = e instanceof HttpError ? e.status : 500;
      const message = e instanceof Error ? e.message : String(e);
      if (status === 500) console.error(e);
      res.status(status).json({ error: message, ...(e instanceof HttpError && e.details ? { details: e.details } : {}) });
    }
  },
);
