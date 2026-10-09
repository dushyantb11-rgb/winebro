/**
 * Catalogue validation shared by every write path of the admin API
 * (create, update, import, publish). Mirrors what the mobile parsers in
 * lib/features/pairing/domain/{product,dish}.dart expect.
 */
export type Problem = string;

export type RefContext = {
  productIds: Set<string>;
  drinkCategories: Set<string>;
  cuisines: Set<string>;
  foodProperties: Set<string>;
  archetypes: Set<string>;
};

export const SCORE_AXES = ["fruit", "acidity", "body", "tannin", "freshness", "complexity"] as const;
export const ID_PATTERN = /^[a-z0-9][a-z0-9-]*$/;

function isRecord(v: unknown): v is Record<string, unknown> {
  return !!v && typeof v === "object" && !Array.isArray(v);
}

/** Validates (and lightly normalises) a product or dish. Returns problems. */
export function validateCatalogueDoc(kind: "products" | "dishes", doc: Record<string, unknown>, refs: RefContext): Problem[] {
  const problems: Problem[] = [];
  const str = (k: string, required: boolean, max = 400) => {
    const v = doc[k];
    if (v === undefined || v === null || v === "") {
      if (required) problems.push(`${k} is required`);
      else if (v === null) doc[k] = undefined;
      return;
    }
    if (typeof v !== "string") problems.push(`${k} must be text`);
    else if (v.length > max) problems.push(`${k} is longer than ${max} characters`);
  };
  const num = (k: string, required: boolean, min: number, max: number) => {
    const v = doc[k];
    if (v === undefined || v === null || v === "") {
      if (required) problems.push(`${k} is required`);
      return;
    }
    if (typeof v !== "number" || Number.isNaN(v)) problems.push(`${k} must be a number`);
    else if (v < min || v > max) problems.push(`${k} must be between ${min} and ${max}`);
  };
  const strList = (k: string, allowed?: Set<string>, max = 50) => {
    const v = doc[k];
    if (v === undefined || v === null) { doc[k] = []; return; }
    if (!Array.isArray(v)) { problems.push(`${k} must be a list`); return; }
    if (v.length > max) problems.push(`${k} has more than ${max} entries`);
    const bad = v.filter((x) => typeof x !== "string");
    if (bad.length) problems.push(`${k} must contain only text`);
    if (allowed) {
      const unknown = v.filter((x) => typeof x === "string" && !allowed.has(x));
      if (unknown.length) problems.push(`${k}: unknown code(s) ${unknown.join(", ")}`);
    }
  };

  if (typeof doc.id !== "string" || !doc.id) problems.push("id is required");
  else if (!ID_PATTERN.test(doc.id)) problems.push("id may use lower-case letters, digits and dashes only");
  str("name", true, 200);
  if (typeof doc.sortOrder !== "number") doc.sortOrder = typeof doc.sortOrder === "string" && doc.sortOrder.trim() !== "" && !Number.isNaN(Number(doc.sortOrder)) ? Number(doc.sortOrder) : 1000;
  if (doc.verified !== undefined && doc.verified !== null && typeof doc.verified !== "boolean") problems.push("verified must be true or false");
  if (doc.archived !== undefined && doc.archived !== null && typeof doc.archived !== "boolean") problems.push("archived must be true or false");
  str("imageUrl", false, 1000);
  if (typeof doc.imageUrl === "string" && doc.imageUrl && !/^https:\/\//.test(doc.imageUrl)) problems.push("imageUrl must start with https://");
  str("source", false, 120);
  str("provenance", false, 120);

  if (kind === "products") {
    str("category", true, 64);
    if (typeof doc.category === "string" && doc.category && refs.drinkCategories.size && !refs.drinkCategories.has(doc.category)) {
      problems.push(`category: unknown code ${doc.category} (add it under Rules → Categories first)`);
    }
    str("subcategory", false, 120);
    str("region", false, 120);
    str("origin", false, 120);
    str("grapeVariety", false, 120);
    str("tastingNotes", false, 2000);
    for (const k of ["subcategory", "region", "tastingNotes"]) if (doc[k] === undefined) doc[k] = "";
    for (const a of SCORE_AXES) num(a, true, 0, 10);
    num("abv", false, 0, 100);
    if (doc.price === undefined || doc.price === null) doc.price = 0;
    else num("price", false, 0, 1_000_000);
    strList("aromas");
    strList("archetypeTags", refs.archetypes.size ? refs.archetypes : undefined);
    if (doc.bestSeller !== undefined && doc.bestSeller !== null) {
      if (!isRecord(doc.bestSeller)) problems.push("bestSeller must be an object");
      else {
        const b = doc.bestSeller;
        if (b.url !== undefined && b.url !== null && b.url !== "" && !/^https?:\/\//.test(String(b.url))) problems.push("bestSeller.url must be a web address");
        if (b.note !== undefined && typeof b.note !== "string") problems.push("bestSeller.note must be text");
      }
    }
    if (doc.estimate !== undefined && doc.estimate !== null && !isRecord(doc.estimate)) problems.push("estimate must be an object");
  } else {
    str("category", true, 64);
    if (typeof doc.category === "string" && doc.category && refs.cuisines.size && !refs.cuisines.has(doc.category)) {
      problems.push(`category: unknown cuisine ${doc.category} (add it under Rules → Categories first)`);
    }
    str("description", false, 2000);
    strList("foodProperties", refs.foodProperties.size ? refs.foodProperties : undefined);
    const pairings = doc.pairings;
    if (pairings === undefined || pairings === null) doc.pairings = [];
    else if (!Array.isArray(pairings)) problems.push("pairings must be a list");
    else {
      const seen = new Set<string>();
      pairings.forEach((p, i) => {
        if (!isRecord(p)) { problems.push(`pairings[${i}] must be an object`); return; }
        const pid = p.productId;
        if (typeof pid !== "string" || !pid) problems.push(`pairings[${i}].productId is required`);
        else if (refs.productIds.size && !refs.productIds.has(pid)) problems.push(`pairings[${i}] points to unknown drink ${pid}`);
        else if (seen.has(pid)) problems.push(`pairings[${i}] repeats drink ${pid}`);
        else seen.add(pid);
        if (typeof p.score !== "number" || p.score < 40 || p.score > 99) problems.push(`pairings[${i}].score must be 40–99`);
        if (p.strategy !== "complement" && p.strategy !== "contrast") problems.push(`pairings[${i}].strategy must be complement or contrast`);
        if (p.broTip === undefined || p.broTip === null) p.broTip = "";
        else if (typeof p.broTip !== "string") problems.push(`pairings[${i}].broTip must be text`);
        else if (p.broTip.length > 500) problems.push(`pairings[${i}].broTip is longer than 500 characters`);
      });
    }
  }
  return problems;
}

/** Deep merge used by merge-mode imports: new values win, nested objects merge, lists replace. */
export function mergeDocs(base: Record<string, unknown>, patch: Record<string, unknown>): Record<string, unknown> {
  const out: Record<string, unknown> = { ...base };
  for (const [k, v] of Object.entries(patch)) {
    if (v === undefined) continue;
    if (isRecord(v) && isRecord(out[k])) out[k] = mergeDocs(out[k] as Record<string, unknown>, v);
    else out[k] = v;
  }
  return out;
}
