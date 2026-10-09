// Thin client for the adminApi function (same origin via Hosting rewrite).
import { idToken } from "./auth";

export type Me = { email: string; name: string; allowed: boolean };
export type Access = { emails: string[]; updatedAt?: string; updatedBy?: string };
export type Doc = Record<string, unknown> & { id: string };
export type Target = "draft" | "live";

export class ApiError extends Error {
  constructor(public status: number, message: string, public details?: unknown) {
    super(message);
  }
}

async function call<T>(method: string, path: string, body?: unknown): Promise<T> {
  const token = await idToken();
  const headers: Record<string, string> = {};
  if (token) headers.Authorization = `Bearer ${token}`;
  if (body !== undefined) headers["Content-Type"] = "application/json";
  const res = await fetch(`/api/${path}`, { method, headers, body: body === undefined ? undefined : JSON.stringify(body) });
  const text = await res.text();
  let data: unknown = null;
  try {
    data = text ? JSON.parse(text) : null;
  } catch {
    data = { error: text };
  }
  if (!res.ok) {
    const d = data as { error?: string; details?: unknown } | null;
    throw new ApiError(res.status, d?.error ?? `${res.status} ${res.statusText}`, d?.details);
  }
  return data as T;
}

export type Stats = {
  drinks: number; dishes: number; verified: number; archived: number; users: number; journalEntries: number; wishlistAdds: number;
  communitySignals: number; pairingFeedback: number; pairingAggregates: number; pendingDrafts: number;
  config: { id: string; version: number; source: string; updatedAt: string | null }[];
};

export type HealthQueue = { title: string; kind: string; hint: string; count: number; ids: { id: string; name?: string }[] };

export type ImportReport = {
  rows: number; valid: number; mode: string; writtenToDrafts: number; created: number; updated: number; wouldWrite?: number; blocked?: boolean;
  errors: { row: number; id: string; problems: string[] }[];
};

export type DraftItem = { kind: "products" | "dishes" | "config"; id: string; name: string; meta: { savedBy?: string; savedAt?: string; isNew?: boolean; via?: string } | null };
export type Release = { id: string; note: string; by: string; at: string; items: { kind: string; id: string; name?: string; hadPrevious?: boolean; archived?: boolean; version?: number }[]; counts: { products: number; dishes: number; config: number } };
export type DocWithDraft = Doc & { live: Doc | null; draft: Doc | null; hasDraft?: boolean; archived?: boolean };

export type SourceCard = { id: string; name: string; kind: string; status: "connected" | "linked" | "unusable"; provides: string; licence: string; records: number; extra?: string };
export type GmAction =
  | { type: "ping" } | { type: "coverage"; country?: string } | { type: "regions"; country?: string } | { type: "producers"; country?: string }
  | { type: "wines"; region_id?: string; producer_id?: string; color?: string } | { type: "search"; q: string } | { type: "details"; ids: string[] }
  | { type: "producer-insights"; id: string } | { type: "region-insights"; id: string } | { type: "licence"; id: string };
export type GmEstimate = { calls: number; left: number; afterwards: number; allowed: boolean; note: string; month: string; used: number; budget: number; limit: number };
export type GmStatus = {
  month: string; used: number; budget: number; limit: number; terms: { commercialOk?: boolean; note?: string; setBy?: string }; lastCall: unknown;
  counts: { wines: number; withDetail: number; producers: number; regions: number; insights: number; licensed: number; mappedProducts: number };
  coverage: Record<string, unknown> | null; recent: { at: string; by: string; url: string; status: number }[];
};
export type GmWine = { id: string; lwin: string | null; name: string; color: string | null; type: string | null; sub_type: string | null; producer: string | null; region: string | null; country: string | null; hasDetail: boolean; licensed: boolean; grapes: unknown; flavor_profile: Record<string, number> | null; source: string | null };
export type GmMatch = { productId: string; name: string; category: string; region?: string; grapeVariety: string | null; mapped: { id: unknown; lwin: unknown; licensed: boolean } | null; candidates: (GmWine & { score: number })[] };

const q = (target?: Target) => (target ? `?target=${target}` : "");

export const api = {
  me: () => call<Me>("GET", "me"),
  access: () => call<Access>("GET", "access"),
  saveAccess: (emails: string[]) => call<Access>("PUT", "access", { emails }),
  stats: () => call<Stats>("GET", "stats"),
  health: () => call<{ queues: HealthQueue[] }>("GET", "health"),
  list: (collection: string) => call<Doc[]>("GET", `collections/${collection}`),
  get: (collection: string, id: string) => call<DocWithDraft>("GET", `collections/${collection}/${encodeURIComponent(id)}`),
  create: (collection: string, doc: Doc, target: Target = "draft") => call<DocWithDraft>("POST", `collections/${collection}${q(target)}`, doc),
  update: (collection: string, id: string, doc: Doc, target: Target = "draft") =>
    call<DocWithDraft>("PUT", `collections/${collection}/${encodeURIComponent(id)}${q(target)}`, doc),
  validate: (collection: string, doc: Record<string, unknown>) => call<{ problems: string[] }>("POST", `collections/${collection}/validate`, { doc }),
  archive: (collection: string, id: string) => call<{ id: string; archived: boolean; references: Record<string, unknown> | null }>("POST", `collections/${collection}/${encodeURIComponent(id)}/archive`),
  restore: (collection: string, id: string) => call<{ id: string; archived: boolean }>("POST", `collections/${collection}/${encodeURIComponent(id)}/restore`),
  remove: (collection: string, id: string) => call<{ deleted: string }>("DELETE", `collections/${collection}/${encodeURIComponent(id)}`),
  importRows: (collection: string, rows: Doc[], mode: "merge" | "replace", dryRun = false) =>
    call<ImportReport>("POST", `collections/${collection}/import`, { rows, mode, dryRun }),
  drafts: () => call<{ items: DraftItem[] }>("GET", "drafts"),
  discardDraft: (kind: string, id: string) => call<{ discarded: string }>("DELETE", `drafts/${kind}/${encodeURIComponent(id)}`),
  publish: (items?: { kind: string; id: string }[], note?: string) => call<{ releaseId: string; items: unknown[] }>("POST", "publish", { items, note }),
  releases: () => call<Release[]>("GET", "releases"),
  rollback: (releaseId: string) => call<{ releaseId: string | null; items: unknown[]; skipped: string[] }>("POST", `releases/${releaseId}/rollback`),
  userSub: (uid: string, sub: string) => call<Doc[]>("GET", `users/${encodeURIComponent(uid)}/${sub}`),
  configAll: () => call<Doc[]>("GET", "config"),
  config: (doc: string) => call<Doc & { draft: Doc | null; readOnly: boolean }>("GET", `config/${doc}`),
  saveConfig: (doc: string, content: Record<string, unknown>, target: Target = "draft") => call<Doc>("PUT", `config/${doc}${q(target)}`, content),
  configHistory: (doc: string) => call<Doc[]>("GET", `config/${doc}/history`),
  restoreConfig: (doc: string, version: string) => call<Doc>("POST", `config/${doc}/restore/${version}`),
  sources: () => call<{ sources: SourceCard[]; totals: { products: number; dishes: number } }>("GET", "sources"),
  gm: {
    status: () => call<GmStatus>("GET", "sources/grapeminds/status"),
    wines: () => call<GmWine[]>("GET", "sources/grapeminds/wines"),
    matches: () => call<GmMatch[]>("GET", "sources/grapeminds/matches"),
    estimate: (action: GmAction) => call<GmEstimate>("POST", "sources/grapeminds/estimate", { action }),
    run: (action: GmAction) => call<{ action: GmAction; estimate: GmEstimate; result: unknown; ledger: GmStatus }>("POST", "sources/grapeminds/run", { action, confirm: true }),
    map: (body: { productId: string; gmId: string; fillEmpty?: boolean; adoptScores?: boolean }) => call<{ productId: string; gmId: string; fills: string[] }>("POST", "sources/grapeminds/map", body),
    create: (body: { gmId: string; id?: string; name?: string }) => call<{ id: string }>("POST", "sources/grapeminds/create", body),
    terms: (body: { commercialOk: boolean; note: string }) => call<{ terms: unknown }>("PUT", "sources/grapeminds/terms", body),
    budget: (budget: number) => call<{ budget: number }>("PUT", "sources/grapeminds/budget", { budget }),
  },
  upload: (path: string, contentType: string, dataBase64: string, rights?: Record<string, string>) =>
    call<{ path: string; url: string; bytes: number }>("POST", "upload", { path, contentType, dataBase64, rights }),
};

export function fileToBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const r = new FileReader();
    r.onload = () => resolve(String(r.result).split(",")[1] ?? "");
    r.onerror = () => reject(r.error);
    r.readAsDataURL(file);
  });
}
