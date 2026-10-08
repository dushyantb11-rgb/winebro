// Field definitions that drive tables, forms, exports and Excel templates.
// Values in Firestore stay exactly as the app reads them (see
// docs/ADMIN-DATA-INVENTORY.md); nested objects are flattened with dots
// in CSV/Excel and rebuilt on import.

export type FieldType =
  | "text" | "textarea" | "number" | "score" | "boolean" | "select" | "tags"
  | "image" | "json" | "pairings" | "readonly";

export type Field = {
  key: string;
  label: string;
  type: FieldType;
  hint?: string;
  required?: boolean;
  options?: string | string[]; // config list name, or fixed options
  min?: number;
  max?: number;
  step?: number;
  table?: boolean;      // show as table column
  card?: boolean;       // show on card
  export?: boolean;     // include in CSV/Excel (default true)
  span?: boolean;       // full width in the form
  section?: string;
};

export type CollectionSpec = {
  id: string;
  title: string;
  singular: string;
  icon: string;
  editable: boolean;
  deletable: boolean;
  description: string;
  fields: Field[];
  imageKey?: string;
  imageFallback?: (doc: Record<string, unknown>) => string | undefined;
  subtitle?: (doc: Record<string, unknown>) => string;
};

const SCORES = ["fruit", "acidity", "body", "tannin", "freshness", "complexity"] as const;

export const products: CollectionSpec = {
  id: "products",
  title: "Drinks",
  singular: "drink",
  icon: "wine_bar",
  editable: true,
  deletable: true,
  description: "Everything the app knows about a drink: facts, taste scores, tags, photo and open data.",
  imageKey: "imageUrl",
  imageFallback: (d) => get(d, "openData.bottlePhoto.imageUrl") ?? get(d, "openData.openFoodFacts.imageUrl"),
  subtitle: (d) => [d.subcategory, d.region].filter(Boolean).join(" · "),
  fields: [
    { key: "id", label: "ID", type: "text", required: true, hint: "lower-case, dashes; cannot change later", section: "Basics", table: true },
    { key: "name", label: "Name", type: "text", required: true, section: "Basics", table: true, card: true },
    { key: "category", label: "Category", type: "select", options: "drinks", required: true, section: "Basics", table: true },
    { key: "subcategory", label: "Style / sub-category", type: "text", section: "Basics", table: true },
    { key: "region", label: "Region", type: "text", section: "Basics", table: true },
    { key: "origin", label: "Country / origin", type: "text", section: "Basics" },
    { key: "abv", label: "ABV %", type: "number", min: 0, max: 100, step: 0.1, section: "Basics", table: true },
    { key: "grapeVariety", label: "Grape / base", type: "text", section: "Basics" },
    { key: "verified", label: "Verified by a person", type: "boolean", section: "Basics", table: true },
    { key: "sortOrder", label: "Sort order", type: "number", step: 1, section: "Basics" },
    ...SCORES.map<Field>((k) => ({ key: k, label: cap(k), type: "score", min: 0, max: 10, step: 0.5, section: "Taste scores (0–10)" })),
    { key: "tastingNotes", label: "Tasting notes", type: "textarea", section: "Story", span: true },
    { key: "aromas", label: "Aromas", type: "tags", section: "Story", span: true },
    { key: "archetypeTags", label: "Suits these palates", type: "tags", options: "archetypes", section: "Story", span: true },
    { key: "bestSeller.note", label: "Best-seller note", type: "text", section: "Story", hint: "Shown in the India's best-sellers row" },
    { key: "bestSeller.source", label: "Best-seller source", type: "text", section: "Story" },
    { key: "bestSeller.url", label: "Best-seller source URL", type: "text", section: "Story" },
    { key: "estimate.label", label: "Estimate label", type: "text", section: "Provenance", hint: "e.g. Estimated from published facts" },
    { key: "estimate.confidence", label: "Estimate confidence", type: "select", options: ["", "high", "medium", "low"], section: "Provenance" },
    { key: "estimate.method", label: "Estimate method", type: "text", section: "Provenance" },
    { key: "estimate.date", label: "Estimate date", type: "text", section: "Provenance" },
    { key: "source", label: "Source", type: "text", section: "Provenance" },
    { key: "provenance", label: "Provenance", type: "text", section: "Provenance" },
    { key: "imageUrl", label: "Photo", type: "image", section: "Photo", span: true },
    { key: "openData", label: "Open data (X-Wines, Open Food Facts, Wikidata, BJCP, Commons)", type: "json", section: "Open data", span: true, export: false },
    { key: "price", label: "Price", type: "readonly", export: false, hint: "Pricing removed; kept at 0" },
    { key: "updatedAt", label: "Updated", type: "readonly", export: false },
  ],
};

export const dishes: CollectionSpec = {
  id: "dishes",
  title: "Dishes",
  singular: "dish",
  icon: "restaurant",
  editable: true,
  deletable: true,
  description: "Indian dishes, their food properties and hand-written pairings with drinks.",
  imageKey: "imageUrl",
  imageFallback: (d) => get(d, "openData.photo.imageUrl"),
  subtitle: (d) => String(d.category ?? ""),
  fields: [
    { key: "id", label: "ID", type: "text", required: true, hint: "lower-case, dashes; cannot change later", section: "Basics", table: true },
    { key: "name", label: "Name", type: "text", required: true, section: "Basics", table: true, card: true },
    { key: "category", label: "Cuisine", type: "select", options: "cuisines", required: true, section: "Basics", table: true },
    { key: "description", label: "Description", type: "textarea", section: "Basics", span: true },
    { key: "foodProperties", label: "Food properties", type: "tags", options: "foodProperties", section: "Basics", span: true, table: true },
    { key: "verified", label: "Verified by a person", type: "boolean", section: "Basics", table: true },
    { key: "sortOrder", label: "Sort order", type: "number", step: 1, section: "Basics" },
    { key: "pairings", label: "Hand-written pairings", type: "pairings", section: "Pairings", span: true, export: false },
    { key: "imageUrl", label: "Photo", type: "image", section: "Photo", span: true },
    { key: "source", label: "Source", type: "text", section: "Provenance" },
    { key: "provenance", label: "Provenance", type: "text", section: "Provenance" },
    { key: "openData", label: "Open data (Indian Food 101, photo)", type: "json", section: "Open data", span: true, export: false },
    { key: "updatedAt", label: "Updated", type: "readonly", export: false },
  ],
};

export const pilot: CollectionSpec = {
  id: "pilot_candidates",
  title: "Pilot candidates",
  singular: "candidate",
  icon: "science",
  editable: true,
  deletable: true,
  description: "Working copy behind the drinks: collected facts, open-data matches and AI estimate rounds.",
  subtitle: (d) => String(d.status ?? ""),
  fields: [
    { key: "id", label: "ID", type: "text", required: true, table: true },
    { key: "name", label: "Name", type: "text", table: true, card: true },
    { key: "category", label: "Category", type: "text", table: true },
    { key: "status", label: "Status", type: "text", table: true },
    { key: "facts", label: "Facts", type: "json", span: true, export: false },
    { key: "aiEstimate", label: "AI estimate", type: "json", span: true, export: false },
    { key: "openData", label: "Open data", type: "json", span: true, export: false },
  ],
};

export const signals: CollectionSpec = {
  id: "community_signals",
  title: "Community signals",
  singular: "signal",
  icon: "groups",
  editable: false,
  deletable: false,
  description: "Computed weekly by the roll-up function from real journal entries. View and export only.",
  fields: [
    { key: "productName", label: "Drink", type: "readonly", table: true, card: true },
    { key: "category", label: "Category", type: "readonly", table: true },
    { key: "region", label: "Region", type: "readonly", table: true },
    { key: "tastersThisWeek", label: "Tasters this week", type: "readonly", table: true },
    { key: "tastersPrevWeek", label: "Tasters last week", type: "readonly", table: true },
    { key: "lovedThisWeek", label: "Loved", type: "readonly", table: true },
    { key: "climbingScore", label: "Climbing score", type: "readonly", table: true },
    { key: "lovedRate", label: "Loved rate", type: "readonly", table: true },
    { key: "topPairing", label: "Top pairing", type: "readonly", table: true },
    { key: "topPairingShare", label: "Top pairing share", type: "readonly" },
    { key: "updatedAt", label: "Updated", type: "readonly", table: true },
  ],
};

export const aggregates: CollectionSpec = {
  id: "pairing_aggregates",
  title: "Pairing votes",
  singular: "aggregate",
  icon: "how_to_vote",
  editable: false,
  deletable: false,
  description: "Yes / maybe / no counts per dish and drink from the 'Did Bro get it right?' prompt.",
  fields: [
    { key: "productId", label: "Drink", type: "readonly", table: true },
    { key: "dishKey", label: "Dish", type: "readonly", table: true },
    { key: "yes", label: "Yes", type: "readonly", table: true },
    { key: "maybe", label: "Maybe", type: "readonly", table: true },
    { key: "no", label: "No", type: "readonly", table: true },
  ],
};

export const feedback: CollectionSpec = {
  id: "pairing_feedback",
  title: "Pairing feedback",
  singular: "response",
  icon: "thumb_up",
  editable: false,
  deletable: true,
  description: "Individual answers to the pairing feedback prompt.",
  fields: [
    { key: "userId", label: "User", type: "readonly", table: true },
    { key: "productName", label: "Drink", type: "readonly", table: true },
    { key: "foodPaired", label: "Food", type: "readonly", table: true },
    { key: "response", label: "Response", type: "readonly", table: true },
    { key: "respondedAt", label: "When", type: "readonly", table: true },
  ],
};

export const phoneIndex: CollectionSpec = {
  id: "phone_index",
  title: "Phone index",
  singular: "entry",
  icon: "contact_phone",
  editable: false,
  deletable: true,
  description: "Hashed phone numbers that let friends find each other. Hash → user id.",
  fields: [
    { key: "id", label: "Hash", type: "readonly", table: true },
    { key: "uid", label: "User", type: "readonly", table: true },
  ],
};

export const COLLECTIONS: CollectionSpec[] = [products, dishes, pilot, signals, aggregates, feedback, phoneIndex];
export const byId = (id: string) => COLLECTIONS.find((c) => c.id === id);

// ── helpers ──────────────────────────────────────────────────────
export function cap(s: string) {
  return s.charAt(0).toUpperCase() + s.slice(1).replace(/([A-Z])/g, " $1");
}

export function get(obj: unknown, path: string): string | undefined {
  const v = getAny(obj, path);
  return v === undefined || v === null ? undefined : String(v);
}

export function getAny(obj: unknown, path: string): unknown {
  return path.split(".").reduce<unknown>((o, k) => (o && typeof o === "object" ? (o as Record<string, unknown>)[k] : undefined), obj);
}

export function setAny(obj: Record<string, unknown>, path: string, value: unknown) {
  const keys = path.split(".");
  let o = obj;
  for (const k of keys.slice(0, -1)) {
    if (!o[k] || typeof o[k] !== "object") o[k] = {};
    o = o[k] as Record<string, unknown>;
  }
  const last = keys[keys.length - 1];
  if (value === undefined) delete o[last];
  else o[last] = value;
}

/** Fields that go to CSV/Excel, in order. */
export function exportFields(spec: CollectionSpec): Field[] {
  return spec.fields.filter((f) => f.export !== false && f.type !== "json" && f.type !== "pairings");
}

export const SCORE_KEYS = SCORES;
