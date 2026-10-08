import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { api, ImportReport } from "../lib/api";
import { CollectionSpec, exportFields } from "../lib/schema";
import { parseImport, downloadTemplate } from "../lib/xlsx";
import { Option } from "../lib/config";
import { Icon, Sheet, useToast } from "./ui";

type Row = Record<string, unknown>;

export function ImportDialog({ spec, onClose, options, example }: {
  spec: CollectionSpec; onClose: () => void; options: Record<string, Option[]>; example?: Row;
}) {
  const toast = useToast();
  const qc = useQueryClient();
  const [rows, setRows] = useState<Row[] | null>(null);
  const [headers, setHeaders] = useState<string[]>([]);
  const [mode, setMode] = useState<"merge" | "replace">("merge");
  const [check, setCheck] = useState<ImportReport | null>(null);
  const [busy, setBusy] = useState(false);
  const [done, setDone] = useState<ImportReport | null>(null);
  const known = new Set(exportFields(spec).map((f) => f.key));
  const unknown = headers.filter((h) => !known.has(h));

  const load = async (file: File) => {
    try {
      const r = await parseImport(spec, file);
      setRows(r.rows);
      setHeaders(r.headers);
      setCheck(null);
      setDone(null);
      const rep = await api.importRows(spec.id, r.rows as never, mode, true);
      setCheck(rep);
    } catch (e) {
      toast(e instanceof Error ? e.message : "Could not read file", "err");
    }
  };

  const run = async () => {
    if (!rows) return;
    setBusy(true);
    try {
      const rep = await api.importRows(spec.id, rows as never, mode);
      setDone(rep);
      void qc.invalidateQueries({ queryKey: ["collection", spec.id] });
      void qc.invalidateQueries({ queryKey: ["stats"] });
      toast(`${rep.written} ${spec.singular}${rep.written === 1 ? "" : "s"} written`);
    } catch (e) {
      toast(e instanceof Error ? e.message : "Import failed", "err");
    } finally {
      setBusy(false);
    }
  };

  const optionsByList: Record<string, string[]> = Object.fromEntries(Object.entries(options).map(([k, v]) => [k, v.map((o) => `${o.value}`)]));

  return (
    <Sheet title={`Import ${spec.title.toLowerCase()}`} onClose={onClose} wide footer={<>
      <button className="btn" onClick={onClose}>{done ? "Close" : "Cancel"}</button>
      {!done && <button className="btn primary" disabled={!rows || busy || !!check?.errors.length} onClick={run}>
        <Icon name="cloud_upload" className="sm" />{busy ? "Writing…" : `Write ${rows?.length ?? 0} rows`}
      </button>}
    </>}>
      <div className="stack" style={{ gap: 16 }}>
        <div className="row between">
          <div className="small muted">1. Download the template, fill it in Excel. 2. Choose the file here. 3. Check the preview and write.</div>
          <button className="btn sm" onClick={() => downloadTemplate(spec, example, optionsByList)}><Icon name="download" className="sm" />Excel template</button>
        </div>
        <div className="row">
          <label className="btn"><Icon name="attach_file" className="sm" />Choose CSV or Excel
            <input type="file" accept=".csv,.xlsx,.xls" hidden onChange={(e) => { const f = e.target.files?.[0]; if (f) void load(f); e.target.value = ""; }} />
          </label>
          <div className="seg">
            <button className={mode === "merge" ? "active" : ""} onClick={() => setMode("merge")}>Merge (keep other fields)</button>
            <button className={mode === "replace" ? "active" : ""} onClick={() => setMode("replace")}>Replace whole rows</button>
          </div>
        </div>
        {rows && (
          <>
            <div className="row">
              <span className="chip info">{rows.length} rows</span>
              {check && <span className={`chip ${check.errors.length ? "err" : "ok"}`}>{check.errors.length ? `${check.errors.length} with problems` : "All rows look fine"}</span>}
              {unknown.length > 0 && <span className="chip warn">Unknown columns kept as-is: {unknown.join(", ")}</span>}
            </div>
            {check && check.errors.length > 0 && (
              <div className="card card-pad" style={{ borderColor: "var(--error)" }}>
                <b>Fix these before writing</b>
                <ul className="small" style={{ margin: "6px 0 0", paddingLeft: 18 }}>
                  {check.errors.slice(0, 30).map((e) => <li key={e.row}>Row {e.row}{e.id ? ` (${e.id})` : ""}: {e.problems.join("; ")}</li>)}
                </ul>
              </div>
            )}
            <div className="card table-wrap" style={{ maxHeight: 360 }}>
              <table className="tbl">
                <thead><tr>{headers.slice(0, 10).map((h) => <th key={h}>{h}</th>)}</tr></thead>
                <tbody>
                  {rows.slice(0, 50).map((r, i) => (
                    <tr key={i}>{headers.slice(0, 10).map((h) => <td key={h}>{cellText(h, r)}</td>)}</tr>
                  ))}
                </tbody>
              </table>
            </div>
            {rows.length > 50 && <div className="small muted">Showing the first 50 rows.</div>}
          </>
        )}
        {done && (
          <div className="card card-pad">
            <b>Done.</b> {done.created} created, {done.updated} updated.
          </div>
        )}
      </div>
    </Sheet>
  );
}

function cellText(path: string, row: Row): string {
  const v = path.split(".").reduce<unknown>((o, k) => (o && typeof o === "object" ? (o as Row)[k] : undefined), row);
  if (v === undefined || v === null) return "";
  if (Array.isArray(v)) return v.join(" | ");
  if (typeof v === "object") return JSON.stringify(v);
  return String(v);
}
