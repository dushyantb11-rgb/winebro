import { useMemo, useState } from "react";
import { CollectionSpec, Field, getAny } from "../lib/schema";
import { fmtDate, fmtNum } from "../lib/format";
import { Option } from "../lib/config";
import { Empty, Icon } from "./ui";

type Row = Record<string, unknown> & { id: string };

export type ListFilters = { q: string; filters: Record<string, string>; sort: string; dir: 1 | -1 };

export function useListState(defaultSort = "name"): [ListFilters, (p: Partial<ListFilters>) => void] {
  const [s, set] = useState<ListFilters>({ q: "", filters: {}, sort: defaultSort, dir: 1 });
  return [s, (p) => set((x) => ({ ...x, ...p }))];
}

export function applyList(rows: Row[], spec: CollectionSpec, st: ListFilters): Row[] {
  const q = st.q.trim().toLowerCase();
  let out = rows;
  if (q) {
    out = out.filter((r) => JSON.stringify(r).toLowerCase().includes(q));
  }
  for (const [k, v] of Object.entries(st.filters)) {
    if (!v) continue;
    out = out.filter((r) => {
      const val = getAny(r, k);
      if (v === "__yes") return val === true;
      if (v === "__no") return !val;
      if (v === "__has") return !!(val ?? spec.imageFallback?.(r));
      if (v === "__missing") return !(val ?? spec.imageFallback?.(r));
      if (Array.isArray(val)) return val.includes(v);
      return String(val ?? "") === v;
    });
  }
  const f = spec.fields.find((x) => x.key === st.sort);
  out = [...out].sort((a, b) => {
    const av = getAny(a, st.sort), bv = getAny(b, st.sort);
    if (av === bv) return 0;
    if (av === undefined || av === null || av === "") return 1;
    if (bv === undefined || bv === null || bv === "") return -1;
    if (f?.type === "number" || f?.type === "score" || typeof av === "number") return (Number(av) - Number(bv)) * st.dir;
    return String(av).localeCompare(String(bv), undefined, { numeric: true, sensitivity: "base" }) * st.dir;
  });
  return out;
}

export function Cell({ field, value, options }: { field: Field; value: unknown; options?: Record<string, Option[]> }) {
  if (value === undefined || value === null || value === "") return <span className="muted">—</span>;
  if (field.type === "boolean") return value ? <span className="chip ok"><Icon name="check" className="sm" />Yes</span> : <span className="chip">No</span>;
  if (field.type === "number" || field.type === "score") return <>{fmtNum(value)}</>;
  if (field.key.endsWith("At") || field.key === "updatedAt") return <>{fmtDate(value)}</>;
  if (Array.isArray(value)) {
    const list = typeof field.options === "string" ? options?.[field.options] : undefined;
    return <div className="chips">{value.slice(0, 4).map((v) => <span key={String(v)} className="chip">{list?.find((o) => o.value === v)?.label ?? String(v)}</span>)}{value.length > 4 && <span className="chip">+{value.length - 4}</span>}</div>;
  }
  if (field.type === "select" && typeof field.options === "string") {
    return <>{options?.[field.options]?.find((o) => o.value === value)?.label ?? String(value)}</>;
  }
  if (typeof value === "object") return <span className="mono">{JSON.stringify(value).slice(0, 60)}</span>;
  return <>{String(value)}</>;
}

export function Table({ spec, rows, st, setSt, onOpen, options }: {
  spec: CollectionSpec; rows: Row[]; st: ListFilters; setSt: (p: Partial<ListFilters>) => void; onOpen: (r: Row) => void; options?: Record<string, Option[]>;
}) {
  const cols = spec.fields.filter((f) => f.table);
  const img = spec.imageKey || spec.imageFallback;
  if (!rows.length) return <Empty icon="search_off" title="Nothing matches" text="Try a different search or clear the filters." />;
  return (
    <div className="card table-wrap">
      <table className="tbl">
        <thead>
          <tr>
            {img && <th style={{ width: 56 }} />}
            {cols.map((c) => (
              <th key={c.key} className={st.sort === c.key ? "sorted" : ""} onClick={() => setSt({ sort: c.key, dir: st.sort === c.key ? (st.dir === 1 ? -1 : 1) : 1 })}>
                {c.label}{st.sort === c.key && <Icon name={st.dir === 1 ? "arrow_drop_up" : "arrow_drop_down"} className="sm" />}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((r) => (
            <tr key={r.id} className="click" onClick={() => onOpen(r)}>
              {img && <td><Thumb spec={spec} row={r} /></td>}
              {cols.map((c) => <td key={c.key} className={c.type === "number" || c.type === "score" ? "num" : ""}><Cell field={c} value={getAny(r, c.key)} options={options} /></td>)}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export function Thumb({ spec, row, large }: { spec: CollectionSpec; row: Row; large?: boolean }) {
  const url = (spec.imageKey ? (row[spec.imageKey] as string | undefined) : undefined) || spec.imageFallback?.(row);
  if (url) return <img className={`thumb ${large ? "lg" : ""}`} src={url} alt="" loading="lazy" />;
  return <div className={`thumb thumb-ph ${large ? "lg" : ""}`}><Icon name={spec.icon} /></div>;
}

export function Cards({ spec, rows, onOpen, options }: { spec: CollectionSpec; rows: Row[]; onOpen: (r: Row) => void; options?: Record<string, Option[]> }) {
  if (!rows.length) return <Empty icon="search_off" title="Nothing matches" text="Try a different search or clear the filters." />;
  const chips = spec.fields.filter((f) => f.table && (f.type === "boolean" || f.type === "select")).slice(0, 2);
  return (
    <div className="grid cards">
      {rows.map((r) => (
        <div key={r.id} className="card item-card" onClick={() => onOpen(r)}>
          {(spec.imageKey || spec.imageFallback) && <Thumb spec={spec} row={r} large />}
          <div className="body">
            <div className="name">{String(r.name ?? r.productName ?? r.id)}</div>
            <div className="sub">{spec.subtitle?.(r) ?? ""}</div>
            <div className="chips">{chips.map((c) => <Cell key={c.key} field={c} value={getAny(r, c.key)} options={options} />)}</div>
          </div>
        </div>
      ))}
    </div>
  );
}

export function FilterBar({ spec, st, setSt, options, rows }: {
  spec: CollectionSpec; st: ListFilters; setSt: (p: Partial<ListFilters>) => void; options?: Record<string, Option[]>; rows: Row[];
}) {
  const selects = spec.fields.filter((f) => f.table && f.type === "select" && typeof f.options === "string");
  const bools = spec.fields.filter((f) => f.table && f.type === "boolean");
  const hasImage = !!(spec.imageKey || spec.imageFallback);
  const values = useMemo(() => {
    const m: Record<string, Set<string>> = {};
    for (const f of selects) m[f.key] = new Set(rows.map((r) => String(getAny(r, f.key) ?? "")).filter(Boolean));
    return m;
  }, [rows, selects]);
  const active = Object.values(st.filters).some(Boolean) || st.q;
  return (
    <div className="toolbar">
      <div className="search"><Icon name="search" /><input className="input" placeholder={`Search ${spec.title.toLowerCase()}…`} value={st.q} onChange={(e) => setSt({ q: e.target.value })} /></div>
      {selects.map((f) => (
        <select key={f.key} className="select" style={{ width: "auto" }} value={st.filters[f.key] ?? ""} onChange={(e) => setSt({ filters: { ...st.filters, [f.key]: e.target.value } })}>
          <option value="">All {f.label.toLowerCase()}</option>
          {[...(values[f.key] ?? [])].sort().map((v) => <option key={v} value={v}>{options?.[f.options as string]?.find((o) => o.value === v)?.label ?? v}</option>)}
        </select>
      ))}
      {bools.map((f) => (
        <select key={f.key} className="select" style={{ width: "auto" }} value={st.filters[f.key] ?? ""} onChange={(e) => setSt({ filters: { ...st.filters, [f.key]: e.target.value } })}>
          <option value="">{f.label}: any</option><option value="__yes">{f.label}: yes</option><option value="__no">{f.label}: no</option>
        </select>
      ))}
      {hasImage && (
        <select className="select" style={{ width: "auto" }} value={st.filters[spec.imageKey ?? "__img"] ?? ""} onChange={(e) => setSt({ filters: { ...st.filters, [spec.imageKey ?? "__img"]: e.target.value } })}>
          <option value="">Photo: any</option><option value="__has">Has photo</option><option value="__missing">No photo</option>
        </select>
      )}
      {active && <button className="btn ghost sm" onClick={() => setSt({ q: "", filters: {} })}><Icon name="filter_alt_off" className="sm" />Clear</button>}
    </div>
  );
}
