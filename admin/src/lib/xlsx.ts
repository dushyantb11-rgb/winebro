import * as XLSX from "xlsx";
import { CollectionSpec, Field, exportFields, getAny, setAny } from "./schema";

type Row = Record<string, unknown>;

function cell(v: unknown): string | number | boolean {
  if (v === null || v === undefined) return "";
  if (Array.isArray(v)) return v.join(" | ");
  if (typeof v === "object") return JSON.stringify(v);
  if (typeof v === "number" || typeof v === "boolean") return v;
  return String(v);
}

/** Flat rows (dotted keys, lists joined with " | ") for export. */
export function flatten(spec: CollectionSpec, docs: Row[]): Row[] {
  const fields = exportFields(spec);
  return docs.map((d) => {
    const out: Row = {};
    for (const f of fields) out[f.key] = cell(getAny(d, f.key));
    return out;
  });
}

function stamp() {
  return new Date().toISOString().slice(0, 10);
}

export function downloadCsv(spec: CollectionSpec, docs: Row[]) {
  const ws = XLSX.utils.json_to_sheet(flatten(spec, docs));
  const csv = XLSX.utils.sheet_to_csv(ws);
  save(new Blob(["﻿" + csv], { type: "text/csv;charset=utf-8" }), `winebro-${spec.id}-${stamp()}.csv`);
}

export function downloadXlsx(spec: CollectionSpec, docs: Row[]) {
  const wb = XLSX.utils.book_new();
  const ws = XLSX.utils.json_to_sheet(flatten(spec, docs));
  autoWidth(ws);
  XLSX.utils.book_append_sheet(wb, ws, spec.title.slice(0, 31));
  XLSX.utils.book_append_sheet(wb, guideSheet(spec), "How to fill");
  XLSX.writeFile(wb, `winebro-${spec.id}-${stamp()}.xlsx`);
}

/** Blank template: header row, one example row, and a guide sheet. */
export function downloadTemplate(spec: CollectionSpec, example?: Row, options?: Record<string, string[]>) {
  const wb = XLSX.utils.book_new();
  const fields = exportFields(spec);
  const header = fields.map((f) => f.key);
  const sample = fields.map((f) => (example ? cell(getAny(example, f.key)) : sampleFor(f)));
  const ws = XLSX.utils.aoa_to_sheet([header, sample]);
  autoWidth(ws);
  XLSX.utils.book_append_sheet(wb, ws, spec.title.slice(0, 31));
  XLSX.utils.book_append_sheet(wb, guideSheet(spec, options), "How to fill");
  XLSX.writeFile(wb, `winebro-${spec.id}-template.xlsx`);
}

function sampleFor(f: Field): string | number | boolean {
  switch (f.type) {
    case "number": return f.key === "abv" ? 13.5 : 0;
    case "score": return 5;
    case "boolean": return false;
    case "tags": return "one | two";
    default: return f.key === "id" ? "my-new-item" : "";
  }
}

function guideSheet(spec: CollectionSpec, options?: Record<string, string[]>) {
  const rows: (string | number)[][] = [["Column", "What to enter", "Required", "Allowed values"]];
  for (const f of exportFields(spec)) {
    const allowed =
      typeof f.options === "string" ? (options?.[f.options] ?? []).join(", ")
      : Array.isArray(f.options) ? f.options.filter(Boolean).join(", ")
      : f.type === "score" ? "0 to 10 (halves allowed)"
      : f.type === "boolean" ? "TRUE / FALSE"
      : f.type === "tags" ? "several values separated by |"
      : "";
    rows.push([f.key, f.hint ?? f.label, f.required ? "yes" : "", allowed]);
  }
  rows.push([]);
  rows.push(["Rows with an existing id update that item; new ids create items."]);
  rows.push(["Leave a cell empty to keep the current value (merge mode) or clear it (replace mode)."]);
  const ws = XLSX.utils.aoa_to_sheet(rows);
  autoWidth(ws);
  return ws;
}

function autoWidth(ws: XLSX.WorkSheet) {
  const data = XLSX.utils.sheet_to_json<unknown[]>(ws, { header: 1 });
  const widths: number[] = [];
  for (const row of data) {
    row.forEach((v, i) => {
      const len = Math.min(60, String(v ?? "").length + 2);
      widths[i] = Math.max(widths[i] ?? 10, len);
    });
  }
  ws["!cols"] = widths.map((wch) => ({ wch }));
}

function save(blob: Blob, name: string) {
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = name;
  a.click();
  setTimeout(() => URL.revokeObjectURL(a.href), 2000);
}

/** Reads the first sheet of a CSV/XLSX file into documents shaped like Firestore rows. */
export async function parseImport(spec: CollectionSpec, file: File): Promise<{ rows: Row[]; headers: string[] }> {
  const buf = await file.arrayBuffer();
  const wb = XLSX.read(buf, { type: "array" });
  const ws = wb.Sheets[wb.SheetNames[0]];
  const raw = XLSX.utils.sheet_to_json<Row>(ws, { defval: "" });
  const fields = new Map(spec.fields.map((f) => [f.key, f]));
  const headers = raw.length ? Object.keys(raw[0]) : [];
  const rows = raw.map((r) => {
    const doc: Row = {};
    for (const [k, v] of Object.entries(r)) {
      const key = k.trim();
      if (!key) continue;
      const f = fields.get(key);
      const val = convert(f, v);
      if (val !== undefined) setAny(doc, key, val);
    }
    return doc;
  });
  return { rows: rows.filter((r) => Object.keys(r).length), headers };
}

function convert(f: Field | undefined, v: unknown): unknown {
  if (v === "" || v === null || v === undefined) return undefined;
  const t = f?.type;
  if (t === "number" || t === "score") {
    const n = typeof v === "number" ? v : Number(String(v).replace(",", "."));
    return Number.isFinite(n) ? n : undefined;
  }
  if (t === "boolean") {
    if (typeof v === "boolean") return v;
    const s = String(v).trim().toLowerCase();
    return ["true", "yes", "1", "y"].includes(s) ? true : ["false", "no", "0", "n"].includes(s) ? false : undefined;
  }
  if (t === "tags") {
    return String(v).split("|").map((s) => s.trim()).filter(Boolean);
  }
  if (typeof v === "string") {
    const s = v.trim();
    if ((s.startsWith("{") && s.endsWith("}")) || (s.startsWith("[") && s.endsWith("]"))) {
      try { return JSON.parse(s); } catch { /* keep text */ }
    }
    return s;
  }
  return v;
}
