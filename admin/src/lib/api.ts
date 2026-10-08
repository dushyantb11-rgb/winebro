// Thin client for the adminApi function (same origin via Hosting rewrite).
import { idToken } from "./auth";

export type Me = { email: string; name: string; allowed: boolean };
export type Access = { emails: string[]; updatedAt?: string; updatedBy?: string };

export type Doc = Record<string, unknown> & { id: string };

export class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

async function call<T>(method: string, path: string, body?: unknown): Promise<T> {
  const token = await idToken();
  const headers: Record<string, string> = {};
  if (token) headers.Authorization = `Bearer ${token}`;
  if (body !== undefined) headers["Content-Type"] = "application/json";
  const res = await fetch(`/api/${path}`, {
    method,
    headers,
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await res.text();
  let data: unknown = null;
  try {
    data = text ? JSON.parse(text) : null;
  } catch {
    data = { error: text };
  }
  if (!res.ok) {
    const msg = (data as { error?: string } | null)?.error ?? `${res.status} ${res.statusText}`;
    throw new ApiError(res.status, msg);
  }
  return data as T;
}

export type Stats = {
  drinks: number; dishes: number; verified: number;
  drinksWithPhoto: number; dishesWithPhoto: number;
  users: number; journalEntries: number; wishlistAdds: number;
  communitySignals: number; pairingFeedback: number; pairingAggregates: number;
  config: { id: string; version: number; source: string; updatedAt: string | null }[];
};

export type ImportReport = {
  written: number; created: number; updated: number; wouldWrite?: number;
  errors: { row: number; id: string; problems: string[] }[];
};

export const api = {
  me: () => call<Me>("GET", "me"),
  access: () => call<Access>("GET", "access"),
  saveAccess: (emails: string[]) => call<Access>("PUT", "access", { emails }),
  stats: () => call<Stats>("GET", "stats"),
  list: (collection: string) => call<Doc[]>("GET", `collections/${collection}`),
  get: (collection: string, id: string) => call<Doc>("GET", `collections/${collection}/${encodeURIComponent(id)}`),
  create: (collection: string, doc: Doc) => call<Doc>("POST", `collections/${collection}`, doc),
  update: (collection: string, id: string, doc: Doc) =>
    call<Doc>("PUT", `collections/${collection}/${encodeURIComponent(id)}`, doc),
  remove: (collection: string, id: string) =>
    call<{ deleted: string }>("DELETE", `collections/${collection}/${encodeURIComponent(id)}`),
  importRows: (collection: string, rows: Doc[], mode: "merge" | "replace", dryRun = false) =>
    call<ImportReport>("POST", `collections/${collection}/import`, { rows, mode, dryRun }),
  userSub: (uid: string, sub: string) => call<Doc[]>("GET", `users/${encodeURIComponent(uid)}/${sub}`),
  configAll: () => call<Doc[]>("GET", "config"),
  config: (doc: string) => call<Doc>("GET", `config/${doc}`),
  saveConfig: (doc: string, content: Record<string, unknown>) => call<Doc>("PUT", `config/${doc}`, content),
  configHistory: (doc: string) => call<Doc[]>("GET", `config/${doc}/history`),
  restoreConfig: (doc: string, version: string) => call<Doc>("POST", `config/${doc}/restore/${version}`),
  upload: (path: string, contentType: string, dataBase64: string) =>
    call<{ path: string; url: string; bytes: number }>("POST", "upload", { path, contentType, dataBase64 }),
};

export function fileToBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const r = new FileReader();
    r.onload = () => resolve(String(r.result).split(",")[1] ?? "");
    r.onerror = () => reject(r.error);
    r.readAsDataURL(file);
  });
}
