/**
 * CF-12: adminApi — JSON API behind the WineBro admin web app.
 *
 * Served at /api/** through Firebase Hosting (site winebro-console). Uses the
 * Admin SDK, so the mobile app's Firestore rules stay locked.
 *
 * Access: every call needs `Authorization: Bearer <Firebase ID token>` from a
 * Google sign-in whose verified email is in Firestore
 * `admin_access/allowlist.emails`. Admins manage that list at /api/access.
 *
 * Routes
 *   GET    /api/me                               who am I, allowed?
 *   GET    /api/access                           allow-list
 *   PUT    /api/access                           {emails}
 *   GET    /api/stats
 *   GET    /api/collections/:name                list (whole collection)
 *   GET    /api/collections/:name/:id
 *   POST   /api/collections/:name                create {id, ...}
 *   PUT    /api/collections/:name/:id            replace
 *   DELETE /api/collections/:name/:id            (users: recursive)
 *   POST   /api/collections/:name/import         {rows, mode: merge|replace}
 *   GET    /api/users/:uid/:sub                  subcollection
 *   GET    /api/config                           all config docs
 *   GET    /api/config/:doc
 *   PUT    /api/config/:doc                      archive, version+1
 *   GET    /api/config/:doc/history
 *   POST   /api/config/:doc/restore/:version
 *   POST   /api/upload                           {path, contentType, dataBase64}
 */
import { randomUUID } from "crypto";
import { onRequest, Request } from "firebase-functions/v2/https";
import type { Response } from "express";
import {
  DocumentData,
  FieldValue,
  Timestamp,
  getFirestore,
} from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { getAuth } from "firebase-admin/auth";

const BUCKET = "winebro.firebasestorage.app";
const ALLOWLIST_REF = ["admin_access", "allowlist"] as const;

/** Catalogue collections the admin may create, edit, import and delete. */
const EDITABLE = new Set(["products", "dishes", "pilot_candidates"]);
/** Collections the admin may read and export, and delete single rows. */
const READABLE = new Set([
  ...EDITABLE,
  "users",
  "community_signals",
  "pairing_aggregates",
  "pairing_feedback",
  "phone_index",
]);
const USER_SUBS = new Set([
  "journal",
  "wishlist",
  "gamification",
  "friends",
  "fcm_token",
  "pre_quiz_seed",
  "cross_category",
  "aroma_calibration",
]);
const CONFIG_DOCS = new Set([
  "pairingRules",
  "archetypes",
  "quiz",
  "scanner",
  "gamification",
  "badges",
  "categories",
  "occasions",
  "journalScales",
  "aromaWheel",
  "home",
  "notifications",
]);

class HttpError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

/** Timestamps become ISO strings so the browser gets plain JSON. */
function plain(value: unknown): unknown {
  if (value instanceof Timestamp) return value.toDate().toISOString();
  if (Array.isArray(value)) return value.map(plain);
  if (value && typeof value === "object") {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
      out[k] = plain(v);
    }
    return out;
  }
  return value;
}

function isRecord(v: unknown): v is Record<string, unknown> {
  return !!v && typeof v === "object" && !Array.isArray(v);
}

const SCORE_AXES = ["fruit", "acidity", "body", "tannin", "freshness", "complexity"];

/** Shape checks for catalogue rows. Returns a list of problems. */
function validate(collection: string, doc: Record<string, unknown>): string[] {
  const problems: string[] = [];
  const str = (k: string) => {
    if (typeof doc[k] !== "string" || !(doc[k] as string).trim()) {
      problems.push(`${k} is required`);
    }
  };
  const num = (k: string, min?: number, max?: number) => {
    const v = doc[k];
    if (typeof v !== "number" || Number.isNaN(v)) {
      problems.push(`${k} must be a number`);
    } else if ((min !== undefined && v < min) || (max !== undefined && v > max)) {
      problems.push(`${k} must be between ${min} and ${max}`);
    }
  };
  const list = (k: string) => {
    if (!Array.isArray(doc[k])) problems.push(`${k} must be a list`);
  };
  str("id");
  if (typeof doc.id === "string" && !/^[a-z0-9][a-z0-9-]*$/.test(doc.id)) {
    problems.push("id may use lower-case letters, digits and dashes only");
  }
  if (collection === "products") {
    str("name");
    str("category");
    for (const a of SCORE_AXES) num(a, 0, 10);
    list("aromas");
    list("archetypeTags");
    if (doc.abv !== undefined && doc.abv !== null) num("abv", 0, 100);
    if (doc.price === undefined) doc.price = 0;
    for (const k of ["subcategory", "region", "tastingNotes"]) {
      if (doc[k] === undefined || doc[k] === null) doc[k] = "";
    }
  } else if (collection === "dishes") {
    str("name");
    str("category");
    list("foodProperties");
    list("pairings");
    if (Array.isArray(doc.pairings)) {
      doc.pairings.forEach((p, i) => {
        if (!isRecord(p)) {
          problems.push(`pairings[${i}] must be an object`);
          return;
        }
        if (typeof p.productId !== "string") problems.push(`pairings[${i}].productId required`);
        if (typeof p.score !== "number") problems.push(`pairings[${i}].score must be a number`);
        if (p.strategy !== "complement" && p.strategy !== "contrast") {
          problems.push(`pairings[${i}].strategy must be complement or contrast`);
        }
        if (typeof p.broTip !== "string") p.broTip = "";
      });
    }
  }
  return problems;
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

async function allowlist(db: FirebaseFirestore.Firestore): Promise<string[]> {
  const snap = await db.collection(ALLOWLIST_REF[0]).doc(ALLOWLIST_REF[1]).get();
  const emails = snap.get("emails");
  return Array.isArray(emails) ? emails.map((e) => String(e).trim().toLowerCase()).filter(Boolean) : [];
}

/** Verifies the Firebase ID token; throws 401 when missing or invalid. */
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
  await ctx.db.collection(ALLOWLIST_REF[0]).doc(ALLOWLIST_REF[1]).set({
    emails,
    updatedAt: FieldValue.serverTimestamp(),
    updatedBy: ctx.caller.email,
  });
  return accessGet(ctx);
}

async function stats({ db }: Ctx) {
  const count = async (q: FirebaseFirestore.Query) => (await q.count().get()).data().count;
  const products = db.collection("products");
  const [
    drinks, dishes, verified, withPhoto, dishPhotos, users, journal, wishlist,
    signals, feedback, aggregates, configSnap,
  ] = await Promise.all([
    count(products),
    count(db.collection("dishes")),
    count(products.where("verified", "==", true)),
    count(products.where("openData.bottlePhoto.imageUrl", ">", "")),
    count(db.collection("dishes").where("openData.photo.imageUrl", ">", "")),
    count(db.collection("users")),
    count(db.collectionGroup("journal")),
    count(db.collectionGroup("wishlist")),
    count(db.collection("community_signals")),
    count(db.collection("pairing_feedback")),
    count(db.collection("pairing_aggregates")),
    db.collection("config").get(),
  ]);
  const ownPhotos = await count(products.where("imageUrl", ">", ""));
  const offPhotos = await count(products.where("openData.openFoodFacts.imageUrl", ">", ""));
  return {
    drinks, dishes, verified,
    drinksWithPhoto: Math.min(drinks, withPhoto + ownPhotos + offPhotos),
    dishesWithPhoto: dishPhotos,
    users, journalEntries: journal, wishlistAdds: wishlist,
    communitySignals: signals, pairingFeedback: feedback, pairingAggregates: aggregates,
    config: configSnap.docs.map((d) => ({
      id: d.id,
      version: d.get("version") ?? 0,
      source: d.get("source") ?? "",
      updatedAt: plain(d.get("updatedAt")),
    })),
  };
}

async function listCollection({ db }: Ctx, name: string) {
  if (!READABLE.has(name)) throw new HttpError(404, `unknown collection ${name}`);
  const snap = await db.collection(name).get();
  return snap.docs.map((d) => ({ ...(plain(d.data()) as object), id: d.id }));
}

async function getDoc({ db }: Ctx, name: string, id: string) {
  if (!READABLE.has(name)) throw new HttpError(404, `unknown collection ${name}`);
  const d = await db.collection(name).doc(id).get();
  if (!d.exists) throw new HttpError(404, "not found");
  return { ...(plain(d.data()) as object), id: d.id };
}

function stripMeta(doc: Record<string, unknown>) {
  const { updatedAt, openDataUpdatedAt, ...rest } = doc;
  void updatedAt;
  void openDataUpdatedAt;
  return rest;
}

async function writeDoc(ctx: Ctx, name: string, id: string, create: boolean) {
  if (!EDITABLE.has(name)) throw new HttpError(403, `${name} is not editable`);
  const body = stripMeta(await readBody(ctx.req));
  body.id = id;
  const problems = validate(name, body);
  if (problems.length) throw new HttpError(422, problems.join("; "));
  const ref = ctx.db.collection(name).doc(id);
  const existing = await ref.get();
  if (create && existing.exists) throw new HttpError(409, `${id} already exists`);
  if (!create && !existing.exists) throw new HttpError(404, "not found");
  const data: DocumentData = {
    ...body,
    source: body.source ?? (existing.get("source") ?? "admin"),
    provenance: body.provenance ?? (existing.get("provenance") ?? "admin-entered"),
    updatedAt: FieldValue.serverTimestamp(),
    updatedBy: ctx.caller.email,
  };
  if (create) data.createdAt = FieldValue.serverTimestamp();
  if (name === "products") {
    // Taste scores started as AI estimates. The moment a person changes
    // any of them, or marks the drink verified, record who and when, so
    // the app can tell an estimate from a reviewed profile.
    const scoresChanged = SCORE_AXES.some((a) => existing.exists && existing.get(a) !== body[a]);
    if (scoresChanged || (create && !isRecord(body.estimate))) {
      const estimate = isRecord(body.estimate) ? { ...body.estimate } : {};
      estimate.reviewedBy = ctx.caller.email;
      estimate.reviewedAt = new Date().toISOString();
      if (!estimate.label) estimate.label = "Reviewed by WineBro";
      data.estimate = estimate;
      data.provenance = "admin-reviewed";
    }
    if (body.verified === true && existing.get("verified") !== true) {
      data.verifiedBy = ctx.caller.email;
      data.verifiedAt = FieldValue.serverTimestamp();
    }
  }
  await ref.set(data);
  return getDoc(ctx, name, id);
}

async function deleteDoc({ db }: Ctx, name: string, id: string) {
  if (!READABLE.has(name)) throw new HttpError(404, `unknown collection ${name}`);
  if (name === "community_signals" || name === "pairing_aggregates") {
    throw new HttpError(403, `${name} rows are computed; they cannot be deleted here`);
  }
  const ref = db.collection(name).doc(id);
  if (!(await ref.get()).exists) throw new HttpError(404, "not found");
  if (name === "users") {
    await db.recursiveDelete(ref);
  } else {
    await ref.delete();
  }
  return { deleted: id };
}

async function importRows(ctx: Ctx, name: string) {
  if (!EDITABLE.has(name)) throw new HttpError(403, `${name} is not editable`);
  const body = await readBody(ctx.req);
  const rows = Array.isArray(body.rows) ? body.rows : null;
  if (!rows) throw new HttpError(400, "rows must be a list");
  const mode = body.mode === "replace" ? "replace" : "merge";
  const report = { written: 0, created: 0, updated: 0, errors: [] as { row: number; id: string; problems: string[] }[] };
  const col = ctx.db.collection(name);
  const valid: Record<string, unknown>[] = [];
  rows.forEach((raw, i) => {
    if (!isRecord(raw)) {
      report.errors.push({ row: i + 1, id: "", problems: ["row is not an object"] });
      return;
    }
    const row = stripMeta(raw);
    if (mode === "replace") {
      const problems = validate(name, row);
      if (problems.length) {
        report.errors.push({ row: i + 1, id: String(row.id ?? ""), problems });
        return;
      }
    } else if (typeof row.id !== "string" || !row.id) {
      report.errors.push({ row: i + 1, id: "", problems: ["id is required"] });
      return;
    }
    valid.push(row);
  });
  if (body.dryRun === true) return { ...report, wouldWrite: valid.length };

  const existingIds = new Set((await col.select().get()).docs.map((d) => d.id));
  for (let i = 0; i < valid.length; i += 400) {
    const batch = ctx.db.batch();
    for (const row of valid.slice(i, i + 400)) {
      const id = row.id as string;
      const ref = col.doc(id);
      const data = { ...row, updatedAt: FieldValue.serverTimestamp() };
      if (existingIds.has(id)) report.updated++;
      else {
        report.created++;
        Object.assign(data, { createdAt: FieldValue.serverTimestamp(), source: row.source ?? "admin-import", provenance: row.provenance ?? "admin-entered" });
      }
      if (mode === "replace") batch.set(ref, data);
      else batch.set(ref, data, { merge: true });
      report.written++;
    }
    await batch.commit();
  }
  return report;
}

async function userSub({ db }: Ctx, uid: string, sub: string) {
  if (!USER_SUBS.has(sub)) throw new HttpError(404, `unknown subcollection ${sub}`);
  const snap = await db.collection("users").doc(uid).collection(sub).get();
  return snap.docs.map((d) => ({ ...(plain(d.data()) as object), id: d.id }));
}

async function configAll({ db }: Ctx) {
  const snap = await db.collection("config").get();
  return snap.docs.map((d) => ({ ...(plain(d.data()) as object), id: d.id }));
}

async function configGet({ db }: Ctx, doc: string) {
  if (!CONFIG_DOCS.has(doc)) throw new HttpError(404, `unknown config ${doc}`);
  const d = await db.collection("config").doc(doc).get();
  if (!d.exists) throw new HttpError(404, "not found");
  return { ...(plain(d.data()) as object), id: d.id };
}

async function configPut(ctx: Ctx, doc: string) {
  if (!CONFIG_DOCS.has(doc)) throw new HttpError(404, `unknown config ${doc}`);
  const body = await readBody(ctx.req);
  const { version: _v, source: _s, updatedAt: _u, id: _i, ...content } = body;
  void _v; void _s; void _u; void _i;
  if (Object.keys(content).length === 0) throw new HttpError(422, "empty content");
  const ref = ctx.db.collection("config").doc(doc);
  await ctx.db.runTransaction(async (tx) => {
    const current = await tx.get(ref);
    const currentVersion = current.exists ? (current.get("version") as number) ?? 0 : 0;
    if (typeof body.version === "number" && body.version !== currentVersion) {
      throw new HttpError(409, `config/${doc} changed meanwhile (v${currentVersion}); reload and retry`);
    }
    if (current.exists) {
      tx.set(ref.collection("history").doc(String(currentVersion)), {
        ...current.data(),
        archivedAt: FieldValue.serverTimestamp(),
      });
    }
    tx.set(ref, {
      ...content,
      version: currentVersion + 1,
      source: "admin",
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: ctx.caller.email,
    });
  });
  return configGet(ctx, doc);
}

async function configHistory({ db }: Ctx, doc: string) {
  if (!CONFIG_DOCS.has(doc)) throw new HttpError(404, `unknown config ${doc}`);
  const snap = await db.collection("config").doc(doc).collection("history").get();
  return snap.docs
    .map((d) => ({ ...(plain(d.data()) as object), id: d.id }))
    .sort((a, b) => Number(b.id) - Number(a.id));
}

async function configRestore(ctx: Ctx, doc: string, version: string) {
  if (!CONFIG_DOCS.has(doc)) throw new HttpError(404, `unknown config ${doc}`);
  const old = await ctx.db.collection("config").doc(doc).collection("history").doc(version).get();
  if (!old.exists) throw new HttpError(404, `no version ${version}`);
  const { version: _v, source: _s, updatedAt: _u, archivedAt: _a, ...content } = old.data() as Record<string, unknown>;
  void _v; void _s; void _u; void _a;
  ctx.req.body = content;
  return configPut(ctx, doc);
}

async function upload(ctx: Ctx) {
  const body = await readBody(ctx.req);
  const path = typeof body.path === "string" ? body.path.replace(/^\/+/, "") : "";
  const contentType = typeof body.contentType === "string" ? body.contentType : "";
  const data = typeof body.dataBase64 === "string" ? body.dataBase64 : "";
  if (!/^catalogue\/(products|dishes|home|categories)\/[A-Za-z0-9._/-]+$/.test(path)) {
    throw new HttpError(422, "path must be catalogue/<products|dishes|home|categories>/<file>");
  }
  if (!/^image\/(jpeg|png|webp)$/.test(contentType)) throw new HttpError(422, "image/jpeg, png or webp only");
  const buffer = Buffer.from(data, "base64");
  if (buffer.length === 0) throw new HttpError(422, "empty file");
  if (buffer.length > 5 * 1024 * 1024) throw new HttpError(413, "image larger than 5 MB");
  const token = randomUUID();
  const file = getStorage().bucket(BUCKET).file(path);
  await file.save(buffer, {
    contentType,
    metadata: { metadata: { firebaseStorageDownloadTokens: token }, cacheControl: "public, max-age=31536000" },
  });
  const url = `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
  return { path, url, bytes: buffer.length };
}

export const adminApi = onRequest(
  { region: "asia-south1", memory: "512MiB", timeoutSeconds: 120, maxInstances: 3 },
  async (req, res) => {
    const db = getFirestore();
    const parts = req.path.replace(/^\/api\/?/, "").split("/").filter(Boolean).map(decodeURIComponent);
    const m = req.method;
    res.set("Cache-Control", "no-store");
    try {
      const caller = await authenticate(req);
      const allowed = (await allowlist(db)).includes(caller.email);
      if (parts[0] === "me" && m === "GET") {
        res.status(200).json({ email: caller.email, name: caller.name, allowed });
        return;
      }
      if (!allowed) throw new HttpError(403, `${caller.email} is not on the admin list`);
      const ctx: Ctx = { db, req, res, caller };
      let result: unknown;
      if (parts[0] === "access" && m === "GET") result = await accessGet(ctx);
      else if (parts[0] === "access" && m === "PUT") result = await accessPut(ctx);
      else if (parts[0] === "stats" && m === "GET") result = await stats(ctx);
      else if (parts[0] === "collections" && parts.length === 2 && m === "GET") result = await listCollection(ctx, parts[1]);
      else if (parts[0] === "collections" && parts.length === 2 && m === "POST") {
        const body = await readBody(req);
        if (typeof body.id !== "string" || !body.id) throw new HttpError(422, "id is required");
        result = await writeDoc(ctx, parts[1], body.id, true);
      } else if (parts[0] === "collections" && parts.length === 3 && parts[2] === "import" && m === "POST") result = await importRows(ctx, parts[1]);
      else if (parts[0] === "collections" && parts.length === 3 && m === "GET") result = await getDoc(ctx, parts[1], parts[2]);
      else if (parts[0] === "collections" && parts.length === 3 && m === "PUT") result = await writeDoc(ctx, parts[1], parts[2], false);
      else if (parts[0] === "collections" && parts.length === 3 && m === "DELETE") result = await deleteDoc(ctx, parts[1], parts[2]);
      else if (parts[0] === "users" && parts.length === 3 && m === "GET") result = await userSub(ctx, parts[1], parts[2]);
      else if (parts[0] === "config" && parts.length === 1 && m === "GET") result = await configAll(ctx);
      else if (parts[0] === "config" && parts.length === 2 && m === "GET") result = await configGet(ctx, parts[1]);
      else if (parts[0] === "config" && parts.length === 2 && m === "PUT") result = await configPut(ctx, parts[1]);
      else if (parts[0] === "config" && parts.length === 3 && parts[2] === "history" && m === "GET") result = await configHistory(ctx, parts[1]);
      else if (parts[0] === "config" && parts.length === 4 && parts[2] === "restore" && m === "POST") result = await configRestore(ctx, parts[1], parts[3]);
      else if (parts[0] === "upload" && m === "POST") result = await upload(ctx);
      else throw new HttpError(404, `no route ${m} /api/${parts.join("/")}`);
      res.status(200).json(result);
    } catch (e) {
      const status = e instanceof HttpError ? e.status : 500;
      const message = e instanceof Error ? e.message : String(e);
      if (status === 500) console.error(e);
      res.status(status).json({ error: message });
    }
  },
);
