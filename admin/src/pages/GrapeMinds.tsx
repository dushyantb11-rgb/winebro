import { useMemo, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Link } from "react-router-dom";
import { api, GmAction, GmEstimate, GmMatch, GmWine } from "../lib/api";
import { fmtDate } from "../lib/format";
import { Layout } from "../components/Layout";
import { Confirm, Empty, Icon, Sheet, Skeleton, Tabs, TextInput, Toggle, useToast } from "../components/ui";

type Tab = "download" | "wines" | "mapping" | "terms";

export default function GrapeMinds() {
  const qc = useQueryClient();
  const toast = useToast();
  const status = useQuery({ queryKey: ["gm", "status"], queryFn: api.gm.status });
  const [tab, setTab] = useState<Tab>("download");
  const [pending, setPending] = useState<{ action: GmAction; estimate: GmEstimate; label: string } | null>(null);
  const [lastResult, setLastResult] = useState<unknown>(null);
  const invalidate = () => { for (const k of ["gm", "sources", "collection", "drafts", "stats"]) void qc.invalidateQueries({ queryKey: [k] }); };

  const run = useMutation({
    mutationFn: (a: GmAction) => api.gm.run(a),
    onSuccess: (r) => { setLastResult(r.result); setPending(null); toast(`Done — ${r.estimate.calls} call${r.estimate.calls === 1 ? "" : "s"} used, ${r.ledger.budget - r.ledger.used} left this month`); invalidate(); },
    onError: (e) => { setPending(null); toast(e instanceof Error ? e.message : "GrapeMinds call failed", "err"); },
  });

  /** Price first, then ask. Nothing is called until the admin confirms. */
  const propose = async (action: GmAction, label: string) => {
    try {
      const est = await api.gm.estimate(action);
      setPending({ action, estimate: est, label });
    } catch (e) {
      toast(e instanceof Error ? e.message : "Could not estimate", "err");
    }
  };

  const s = status.data;
  const left = s ? s.budget - s.used : 0;

  return (
    <Layout title="GrapeMinds" crumbs="Data Cellar · wine identity, grapes, flavour profiles" actions={<Link className="btn" to="/sources"><Icon name="arrow_back" className="sm" />Data Cellar</Link>}>
      {status.isLoading || !s ? <Skeleton /> : (
        <>
          <div className="grid kpis">
            <div className="card kpi"><Icon name="toll" fill /><div className="v">{left}</div><div className="l">Calls left in {s.month}</div><div className="s">{s.used} used of {s.budget} planned (plan limit {s.limit})</div><div className="bar accent"><i style={{ width: `${Math.round((s.used / s.budget) * 100)}%` }} /></div></div>
            <div className="card kpi"><Icon name="wine_bar" fill /><div className="v">{s.counts.wines}</div><div className="l">Wines downloaded</div><div className="s">{s.counts.withDetail} with full detail</div></div>
            <div className="card kpi"><Icon name="link" fill /><div className="v">{s.counts.mappedProducts}</div><div className="l">Our drinks mapped</div><div className="s">{s.counts.licensed} licensed wines</div></div>
            <div className="card kpi"><Icon name="factory" fill /><div className="v">{s.counts.producers}</div><div className="l">Producers</div><div className="s">{s.counts.regions} regions · {s.counts.insights} insights</div></div>
          </div>
          {!s.terms?.commercialOk && <div className="chip warn"><Icon name="gavel" className="sm" />Publishing GrapeMinds-derived fields is blocked until a wine is licensed or GrapeMinds' written confirmation is recorded under Terms.</div>}

          <Tabs value={tab} onChange={setTab} tabs={[{ id: "download", label: "Download" }, { id: "wines", label: `Downloaded wines (${s.counts.wines})` }, { id: "mapping", label: "Map to our drinks" }, { id: "terms", label: "Terms & budget" }]} />

          {tab === "download" && <DownloadTab status={s} propose={propose} lastResult={lastResult} />}
          {tab === "wines" && <WinesTab propose={propose} />}
          {tab === "mapping" && <MappingTab propose={propose} />}
          {tab === "terms" && <TermsTab status={s} />}
        </>
      )}

      {pending && (
        <Confirm title={pending.label} danger={false} confirmLabel={pending.estimate.allowed ? `Use ${pending.estimate.calls} call${pending.estimate.calls === 1 ? "" : "s"}` : "Not enough calls"} busy={run.isPending}
          onClose={() => setPending(null)} onConfirm={() => pending.estimate.allowed && run.mutate(pending.action)}
          text={<div className="stack">
            <div className="row"><span className="pill-num" style={{ fontSize: 18 }}>{pending.estimate.calls}</span><span>call{pending.estimate.calls === 1 ? "" : "s"} · {pending.estimate.left} left now → {pending.estimate.afterwards} afterwards</span></div>
            {pending.estimate.note && <span className="small muted">{pending.estimate.note}</span>}
            <span className="small muted">Results are stored in Firestore; the same call is never paid twice. Nothing reaches the app until you map and publish.</span>
          </div>} />
      )}
    </Layout>
  );
}

function DownloadTab({ status, propose, lastResult }: { status: NonNullable<ReturnType<typeof useQuery<Awaited<ReturnType<typeof api.gm.status>>>>["data"]>; propose: (a: GmAction, label: string) => void; lastResult: unknown }) {
  const [country, setCountry] = useState("IN");
  const [query, setQuery] = useState("");
  const [regionId, setRegionId] = useState("");
  const [producerId, setProducerId] = useState("");
  const cov = status.coverage && typeof status.coverage === "object" ? (status.coverage as Record<string, unknown>)[country] as Record<string, unknown> | undefined : undefined;
  return (
    <div className="grid two">
      <div className="card">
        <div className="card-head"><h3>Catalogue pulls</h3><span className="small muted">priced before they run</span></div>
        <div className="card-pad stack">
          <div className="row"><span className="small muted">Country</span><TextInput value={country} onChange={(e) => setCountry(e.target.value.toUpperCase().slice(0, 2))} style={{ width: 70 }} /></div>
          <Action label={`Check ${country} coverage`} hint="How many wines, producers and regions GrapeMinds has for this country, and how many already carry grapes and descriptions." cost="1 call" onClick={() => propose({ type: "coverage", country }, `Check ${country} coverage`)} />
          {cov && <div className="card card-pad small" style={{ background: "var(--surface-1)" }}><b>{country} coverage:</b> {String(cov.wines ?? "?")} wines · {String(cov.producers ?? "?")} producers · {String(cov.regions ?? "?")} regions{cov.enrichment && typeof cov.enrichment === "object" ? ` · with grapes ${String((cov.enrichment as Record<string, unknown>).with_grapes)} · with descriptions ${String((cov.enrichment as Record<string, unknown>).with_descriptions)}` : ""}</div>}
          <Action label={`Download ${country} regions`} hint="Region ids are needed to list wines by region." cost="1 call" onClick={() => propose({ type: "regions", country }, `Download ${country} regions`)} />
          <Action label={`Download ${country} producers`} hint="Up to 100 per call; extra pages fetched automatically." cost="1+ calls" onClick={() => propose({ type: "producers", country }, `Download ${country} producers`)} />
          <div className="rule" style={{ gridTemplateColumns: "1fr" }}>
            <div className="stack" style={{ gap: 8 }}>
              <b>Download a wine list</b>
              <div className="small muted">100 wines per call. Filter by region or producer id (from the downloads above); leave both empty for the whole catalogue (expensive — thousands of pages).</div>
              <div className="row"><TextInput placeholder="region id" value={regionId} onChange={(e) => setRegionId(e.target.value)} style={{ width: 140 }} /><TextInput placeholder="producer id" value={producerId} onChange={(e) => setProducerId(e.target.value)} style={{ width: 140 }} />
                <button className="btn primary sm" disabled={!regionId && !producerId} onClick={() => propose({ type: "wines", region_id: regionId || undefined, producer_id: producerId || undefined }, `Download wines (${regionId ? `region ${regionId}` : `producer ${producerId}`})`)}><Icon name="download" className="sm" />Price it</button></div>
            </div>
          </div>
          <div className="rule" style={{ gridTemplateColumns: "1fr" }}>
            <div className="stack" style={{ gap: 8 }}>
              <b>Search by name</b>
              <div className="small muted">For imported wines (Jacob's Creek, Penfolds, Yellow Tail…). 1 call per search, up to 100 results.</div>
              <div className="row"><TextInput placeholder="e.g. Jacob's Creek Shiraz" value={query} onChange={(e) => setQuery(e.target.value)} style={{ flex: 1 }} /><button className="btn primary sm" disabled={query.trim().length < 3} onClick={() => propose({ type: "search", q: query.trim() }, `Search “${query.trim()}”`)}><Icon name="search" className="sm" />Price it</button></div>
            </div>
          </div>
          <Action label="Test the key (ping)" hint="Confirms the key works. Costs a call." cost="1 call" onClick={() => propose({ type: "ping" }, "Test the key")} />
        </div>
      </div>
      <div className="stack">
        <div className="card">
          <div className="card-head"><h3>Last result</h3></div>
          <div className="card-pad"><pre className="mono" style={{ whiteSpace: "pre-wrap", maxHeight: 360, overflow: "auto", margin: 0 }}>{lastResult ? JSON.stringify(lastResult, null, 2).slice(0, 6000) : "Run an action to see its result here."}</pre></div>
        </div>
        <div className="card">
          <div className="card-head"><h3>Recent calls</h3></div>
          <div className="table-wrap" style={{ maxHeight: 260 }}>
            <table className="tbl"><tbody>
              {status.recent.length === 0 ? <tr><td className="muted">No calls yet this month.</td></tr> : status.recent.map((r, i) => <tr key={i}><td>{fmtDate(r.at)}</td><td className="mono small">{r.url}</td><td>{r.by}</td><td><span className={`chip ${r.status < 300 ? "ok" : "err"}`}>{r.status}</span></td></tr>)}
            </tbody></table>
          </div>
        </div>
      </div>
    </div>
  );
}

function Action({ label, hint, cost, onClick }: { label: string; hint: string; cost: string; onClick: () => void }) {
  return (
    <div className="rule">
      <div className="stack" style={{ gap: 4 }}><b>{label}</b><span className="small muted">{hint}</span></div>
      <button className="btn sm" onClick={onClick}><Icon name="sell" className="sm" />{cost}</button>
    </div>
  );
}

function WinesTab({ propose }: { propose: (a: GmAction, label: string) => void }) {
  const q = useQuery({ queryKey: ["gm", "wines"], queryFn: api.gm.wines });
  const toast = useToast();
  const qc = useQueryClient();
  const [filter, setFilter] = useState("");
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [createFor, setCreateFor] = useState<GmWine | null>(null);
  const rows = useMemo(() => (q.data ?? []).filter((w) => !filter || JSON.stringify(w).toLowerCase().includes(filter.toLowerCase())).sort((a, b) => a.name.localeCompare(b.name)), [q.data, filter]);
  const create = useMutation({
    mutationFn: (w: GmWine) => api.gm.create({ gmId: w.id }),
    onSuccess: (r) => { toast(`Draft drink ${r.id} created — review it, preview, then publish`); setCreateFor(null); void qc.invalidateQueries({ queryKey: ["drafts"] }); void qc.invalidateQueries({ queryKey: ["collection", "products"] }); },
    onError: (e) => toast(e instanceof Error ? e.message : "Could not create", "err"),
  });
  if (q.isLoading) return <Skeleton />;
  if (!q.data?.length) return <Empty icon="wine_bar" title="No wines downloaded yet" text="Use the Download tab: coverage → regions → wine list." />;
  return (
    <div className="card">
      <div className="card-head">
        <div className="toolbar" style={{ flex: 1 }}><div className="search"><Icon name="search" /><input className="input" placeholder="Filter downloaded wines…" value={filter} onChange={(e) => setFilter(e.target.value)} /></div></div>
        <button className="btn primary sm" disabled={!selected.size} onClick={() => propose({ type: "details", ids: [...selected] }, `Download details for ${selected.size} wine${selected.size === 1 ? "" : "s"}`)}><Icon name="download" className="sm" />Details for {selected.size} selected</button>
      </div>
      <div className="table-wrap" style={{ maxHeight: 560 }}>
        <table className="tbl">
          <thead><tr><th style={{ width: 36 }}><input type="checkbox" checked={selected.size > 0 && selected.size === rows.length} onChange={(e) => setSelected(e.target.checked ? new Set(rows.map((r) => r.id)) : new Set())} /></th><th>Wine</th><th>Producer</th><th>Region</th><th>Colour</th><th>Type</th><th>Detail</th><th>Profile</th><th /></tr></thead>
          <tbody>
            {rows.map((w) => (
              <tr key={w.id}>
                <td><input type="checkbox" checked={selected.has(w.id)} onChange={() => setSelected((s) => { const n = new Set(s); n.has(w.id) ? n.delete(w.id) : n.add(w.id); return n; })} /></td>
                <td><b>{w.name}</b><div className="small muted mono">{w.id}{w.lwin ? ` · LWIN ${w.lwin}` : ""}</div></td>
                <td>{w.producer ?? "—"}</td><td>{w.region ?? "—"}{w.country ? ` (${w.country})` : ""}</td><td>{w.color ?? "—"}</td><td>{w.sub_type ?? w.type ?? "—"}</td>
                <td>{w.hasDetail ? <span className="chip ok">yes</span> : <span className="chip">list only</span>}{w.licensed && <span className="chip accent" style={{ marginLeft: 4 }}>licensed</span>}</td>
                <td className="small">{w.flavor_profile ? Object.entries(w.flavor_profile).map(([k, v]) => `${k.slice(0, 3)} ${v}`).join(" · ") : "—"}</td>
                <td className="row end"><button className="btn sm" disabled={!w.hasDetail} title={w.hasDetail ? "Create a draft drink from this row" : "Download details first"} onClick={() => setCreateFor(w)}><Icon name="add" className="sm" />Add as drink</button></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {createFor && <Confirm title={`Add “${createFor.name}” as a new drink?`} danger={false} confirmLabel="Create draft" busy={create.isPending} onClose={() => setCreateFor(null)} onConfirm={() => create.mutate(createFor)} text="A draft drink is created with GrapeMinds facts (category, producer, region, grapes, acidity/tannin/body). You review it, preview it, then publish." />}
    </div>
  );
}

function MappingTab({ propose }: { propose: (a: GmAction, label: string) => void }) {
  const q = useQuery({ queryKey: ["gm", "matches"], queryFn: api.gm.matches });
  const toast = useToast();
  const qc = useQueryClient();
  const [adopt, setAdopt] = useState(false);
  const [pick, setPick] = useState<{ m: GmMatch; c: GmWine & { score: number } } | null>(null);
  const map = useMutation({
    mutationFn: (v: { productId: string; gmId: string }) => api.gm.map({ ...v, fillEmpty: true, adoptScores: adopt }),
    onSuccess: (r) => { toast(`Draft saved for ${r.productId}${r.fills.length ? ` (filled: ${r.fills.join(", ")})` : ""} — preview and publish from the drink page`); setPick(null); for (const k of ["gm", "drafts", "collection", "doc"]) void qc.invalidateQueries({ queryKey: [k] }); },
    onError: (e) => toast(e instanceof Error ? e.message : "Mapping failed", "err"),
  });
  if (q.isLoading) return <Skeleton />;
  const list = q.data ?? [];
  const unmatched = list.filter((m) => !m.candidates.length && !m.mapped);
  return (
    <div className="stack">
      <div className="row between">
        <div className="small muted">Our {list.length} wines against the downloaded GrapeMinds rows. Pick the right match; it is written as a draft with <span className="mono">openData.grapeminds</span>, filling empty grape/region/style. Then preview and publish like any edit.</div>
        <Toggle checked={adopt} onChange={setAdopt} label="Also adopt acidity, tannin and body from GrapeMinds" />
      </div>
      {unmatched.length > 0 && <div className="chip warn"><Icon name="search_off" className="sm" />{unmatched.length} of our wines have no candidate yet — use Download → Search by name for them: {unmatched.slice(0, 6).map((m) => m.name).join(", ")}{unmatched.length > 6 ? "…" : ""}</div>}
      <div className="card table-wrap">
        <table className="tbl">
          <thead><tr><th>Our wine</th><th>Mapped</th><th>Best GrapeMinds candidates</th></tr></thead>
          <tbody>
            {list.map((m) => (
              <tr key={m.productId}>
                <td><Link to={`/c/products/${encodeURIComponent(m.productId)}`}><b>{m.name}</b></Link><div className="small muted">{m.category}{m.region ? ` · ${m.region}` : ""}{m.grapeVariety ? ` · ${m.grapeVariety}` : ""}</div></td>
                <td>{m.mapped ? <span className="chip ok">GM {String(m.mapped.id)}{m.mapped.licensed ? " · licensed" : ""}</span> : <span className="chip">not yet</span>}</td>
                <td>
                  <div className="chips">
                    {m.candidates.map((c) => (
                      <button key={c.id} className="chip" style={{ cursor: "pointer", border: "1px solid var(--line-strong)" }} title={`${c.producer ?? ""} · ${c.region ?? ""} · ${c.hasDetail ? "detail downloaded" : "list only"}`} onClick={() => (c.hasDetail ? setPick({ m, c }) : propose({ type: "details", ids: [c.id] }, `Download details for ${c.name}`))}>
                        {Math.round(c.score * 100)}% · {c.name}{c.hasDetail ? "" : " ↓"}
                      </button>
                    ))}
                    {m.candidates.length === 0 && <span className="small muted">—</span>}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {pick && (
        <Sheet title={`Map “${pick.m.name}” → “${pick.c.name}”`} onClose={() => setPick(null)} footer={<><button className="btn" onClick={() => setPick(null)}>Cancel</button><button className="btn primary" disabled={map.isPending} onClick={() => map.mutate({ productId: pick.m.productId, gmId: pick.c.id })}><Icon name="link" className="sm" />Save as draft</button></>}>
          <dl className="kv">
            <dt>GrapeMinds</dt><dd>{pick.c.name} · {pick.c.producer ?? ""} · {pick.c.region ?? ""} {pick.c.lwin ? `· LWIN ${pick.c.lwin}` : ""}</dd>
            <dt>Grapes</dt><dd>{Array.isArray(pick.c.grapes) ? (pick.c.grapes as unknown[]).map((g) => (typeof g === "object" && g ? String((g as Record<string, unknown>).name ?? "") : String(g))).join(", ") : "—"}</dd>
            <dt>Flavour profile</dt><dd>{pick.c.flavor_profile ? Object.entries(pick.c.flavor_profile).map(([k, v]) => `${k} ${v}`).join(" · ") : "—"}</dd>
            <dt>Adopt scores</dt><dd>{adopt ? "Yes — acidity, tannin, body replace our estimates (label updated)" : "No — stored under open data only"}</dd>
            <dt>Licence</dt><dd>{pick.c.licensed ? "Licensed" : "Not licensed — publish stays blocked until licensed or terms recorded"}</dd>
          </dl>
        </Sheet>
      )}
    </div>
  );
}

function TermsTab({ status }: { status: Awaited<ReturnType<typeof api.gm.status>> }) {
  const toast = useToast();
  const qc = useQueryClient();
  const [ok, setOk] = useState(status.terms?.commercialOk === true);
  const [note, setNote] = useState(status.terms?.note ?? "");
  const [budget, setBudget] = useState(String(status.budget));
  const save = useMutation({ mutationFn: () => api.gm.terms({ commercialOk: ok, note }), onSuccess: () => { toast("Terms recorded"); void qc.invalidateQueries({ queryKey: ["gm"] }); }, onError: (e) => toast(e instanceof Error ? e.message : "Failed", "err") });
  const saveBudget = useMutation({ mutationFn: () => api.gm.budget(Number(budget)), onSuccess: (r) => { toast(`Monthly ceiling set to ${r.budget} calls`); void qc.invalidateQueries({ queryKey: ["gm"] }); }, onError: (e) => toast(e instanceof Error ? e.message : "Failed", "err") });
  return (
    <div className="grid two">
      <div className="card"><div className="card-head"><h3>Licence & terms</h3></div><div className="card-pad stack">
        <div className="small muted">GrapeMinds names commercial use on its Startup plan and sells a per-wine licence (~€0.38) to store a wine's data permanently. Until a wine is licensed, publishing fields taken from GrapeMinds is blocked. If GrapeMinds confirms in writing that our plan allows it, record that here and the block lifts.</div>
        <Toggle checked={ok} onChange={setOk} label="GrapeMinds has confirmed in writing that we may store and display their data in WineBro" />
        <textarea className="textarea" placeholder="Paste the confirmation (date, person, wording) or the plan/invoice reference" value={note} onChange={(e) => setNote(e.target.value)} />
        <div className="row end"><button className="btn primary" disabled={save.isPending || (ok && note.trim().length < 10)} onClick={() => save.mutate()}><Icon name="save" className="sm" />Record</button></div>
        {status.terms?.setBy && <div className="small muted">Last set by {status.terms.setBy}</div>}
      </div></div>
      <div className="card"><div className="card-head"><h3>Monthly ceiling</h3></div><div className="card-pad stack">
        <div className="small muted">The free plan allows {status.limit} calls per calendar month. We stop at a lower ceiling to keep a reserve for retries.</div>
        <div className="row"><TextInput type="number" value={budget} onChange={(e) => setBudget(e.target.value)} style={{ width: 120 }} /><button className="btn" disabled={saveBudget.isPending} onClick={() => saveBudget.mutate()}>Set</button></div>
        <div className="small muted">Used {status.used} in {status.month}.</div>
      </div></div>
    </div>
  );
}
