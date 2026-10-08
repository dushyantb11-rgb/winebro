export function fmtDate(v: unknown): string {
  if (!v) return "";
  const d = typeof v === "string" || typeof v === "number" ? new Date(v) : null;
  if (!d || Number.isNaN(d.getTime())) return String(v);
  return d.toLocaleString("en-IN", { day: "2-digit", month: "short", year: "numeric", hour: "2-digit", minute: "2-digit" });
}

export function fmtNum(v: unknown, digits = 1): string {
  if (typeof v !== "number") return v === undefined || v === null ? "" : String(v);
  return Number.isInteger(v) ? String(v) : v.toFixed(digits);
}

export function pct(part: number, whole: number): number {
  return whole ? Math.round((part / whole) * 100) : 0;
}

export function slug(s: string): string {
  return s.toLowerCase().normalize("NFKD").replace(/[̀-ͯ]/g, "").replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
}

export function plural(n: number, one: string, many = `${one}s`) {
  return `${n} ${n === 1 ? one : many}`;
}
