import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Link } from "react-router-dom";
import { api, ApiError, DraftItem } from "../lib/api";
import { fmtDate } from "../lib/format";
import { Layout } from "../components/Layout";
import { Confirm, Empty, Icon, Skeleton, Toggle, useToast } from "../components/ui";

const kindLabel: Record<string, string> = { products: "Drink", dishes: "Dish", config: "Rules" };
const linkFor = (d: DraftItem) => (d.kind === "config" ? `/rules/${d.id}` : `/c/${d.kind}/${encodeURIComponent(d.id)}`);

export default function Releases() {
  const qc = useQueryClient();
  const toast = useToast();
  const drafts = useQuery({ queryKey: ["drafts"], queryFn: api.drafts });
  const releases = useQuery({ queryKey: ["releases"], queryFn: api.releases });
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [note, setNote] = useState("");
  const [confirmPublish, setConfirmPublish] = useState(false);
  const [rollbackId, setRollbackId] = useState<string | null>(null);
  const [problems, setProblems] = useState<{ kind: string; id: string; problems: string[] }[] | null>(null);
  const invalidate = () => {
    for (const k of ["drafts", "releases", "stats", "config", "collection", "doc", "configdoc"]) void qc.invalidateQueries({ queryKey: [k] });
  };
  const publish = useMutation({
    mutationFn: () => api.publish(selected.size ? [...selected].map((k) => ({ kind: k.split("/")[0], id: k.slice(k.indexOf("/") + 1) })) : undefined, note),
    onSuccess: (r) => { toast(`Published release ${r.releaseId} (${r.items.length} items). The app uses it now.`); setSelected(new Set()); setNote(""); setConfirmPublish(false); setProblems(null); invalidate(); },
    onError: (e) => {
      setConfirmPublish(false);
      if (e instanceof ApiError && e.status === 422 && e.details && (e.details as { problems?: unknown }).problems) setProblems((e.details as { problems: { kind: string; id: string; problems: string[] }[] }).problems);
      toast(e instanceof Error ? e.message : "Publish failed", "err");
    },
  });
  const discard = useMutation({
    mutationFn: (d: DraftItem) => api.discardDraft(d.kind, d.id),
    onSuccess: () => { toast("Draft discarded"); invalidate(); },
    onError: (e) => toast(e instanceof Error ? e.message : "Could not discard", "err"),
  });
  const rollback = useMutation({
    mutationFn: (id: string) => api.rollback(id),
    onSuccess: (r) => { toast(r.releaseId ? `Rolled back as release ${r.releaseId}` : "Nothing to roll back"); if (r.skipped.length) toast(`Skipped: ${r.skipped.join(", ")}`, "err"); setRollbackId(null); invalidate(); },
    onError: (e) => toast(e instanceof Error ? e.message : "Rollback failed", "err"),
  });

  const items = drafts.data?.items ?? [];
  const key = (d: DraftItem) => `${d.kind}/${d.id}`;
  const toggle = (d: DraftItem) => setSelected((s) => { const n = new Set(s); n.has(key(d)) ? n.delete(key(d)) : n.add(key(d)); return n; });
  const count = selected.size || items.length;

  return (
    <Layout title="Releases" crumbs="Drafts → publish → history" actions={<>
      <button className="btn primary" disabled={!items.length || publish.isPending} onClick={() => setConfirmPublish(true)}><Icon name="rocket_launch" className="sm" />Publish {selected.size ? `${selected.size} selected` : `all (${items.length})`}</button>
    </>}>
      <div className="small muted">Edits are saved as drafts and are visible only in the console preview and to admins who switch on "Preview console drafts" in the app. Publishing makes them live for everyone and keeps the previous copy, so a release can be rolled back.</div>

      <div className="card">
        <div className="card-head"><h3>Pending drafts</h3><span className="small muted">{items.length} waiting</span></div>
        {drafts.isLoading ? <Skeleton /> : items.length === 0 ? <Empty icon="task_alt" title="Nothing waiting to be published" text="Edit a drink, dish or rules document and save it as a draft." /> : (
          <div className="table-wrap">
            <table className="tbl">
              <thead><tr><th style={{ width: 36 }} /><th>Type</th><th>Item</th><th>Saved by</th><th>When</th><th /></tr></thead>
              <tbody>
                {items.map((d) => (
                  <tr key={key(d)}>
                    <td><input type="checkbox" checked={selected.has(key(d))} onChange={() => toggle(d)} /></td>
                    <td><span className="chip">{kindLabel[d.kind] ?? d.kind}{d.meta?.isNew ? " · new" : ""}{d.meta?.via === "import" ? " · import" : ""}</span></td>
                    <td><Link to={linkFor(d)}><b>{d.name}</b></Link><div className="small muted mono">{d.id}</div></td>
                    <td>{d.meta?.savedBy ?? ""}</td>
                    <td>{fmtDate(d.meta?.savedAt)}</td>
                    <td className="row end"><button className="btn sm ghost" onClick={() => discard.mutate(d)} disabled={discard.isPending}><Icon name="delete" className="sm" />Discard</button></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        {problems && (
          <div className="card-pad" style={{ borderTop: "1px solid var(--line)" }}>
            <b style={{ color: "var(--error)" }}>Publish blocked — fix these drafts first</b>
            <ul className="small" style={{ margin: "6px 0 0", paddingLeft: 18 }}>
              {problems.map((p) => <li key={`${p.kind}/${p.id}`}><Link to={p.kind === "config" ? `/rules/${p.id}` : `/c/${p.kind}/${encodeURIComponent(p.id)}`}>{p.kind}/{p.id}</Link>: {p.problems.join("; ")}</li>)}
            </ul>
          </div>
        )}
      </div>

      <div className="card">
        <div className="card-head"><h3>Release history</h3></div>
        {releases.isLoading ? <Skeleton /> : !releases.data?.length ? <Empty icon="history" title="No releases yet" /> : (
          <div className="table-wrap">
            <table className="tbl">
              <thead><tr><th>Release</th><th>When</th><th>By</th><th>Note</th><th>Items</th><th /></tr></thead>
              <tbody>
                {releases.data.map((r) => (
                  <tr key={r.id}>
                    <td className="mono">{r.id}</td>
                    <td>{fmtDate(r.at)}</td>
                    <td>{r.by}</td>
                    <td>{r.note}</td>
                    <td><span className="chip">{r.counts.products} drinks</span> <span className="chip">{r.counts.dishes} dishes</span> <span className="chip">{r.counts.config} rules</span></td>
                    <td className="row end"><button className="btn sm" onClick={() => setRollbackId(r.id)}><Icon name="undo" className="sm" />Roll back</button></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {confirmPublish && (
        <Confirm title={`Publish ${count} item${count === 1 ? "" : "s"}?`} danger={false} confirmLabel="Publish" busy={publish.isPending} onClose={() => setConfirmPublish(false)} onConfirm={() => publish.mutate()}
          text={<div className="stack">
            <span>Every draft is checked again before anything goes live; if one has a problem, nothing is published. The app picks up the release on its next screen open.</span>
            <input className="input" placeholder="Release note (optional)" value={note} onChange={(e) => setNote(e.target.value)} />
            <Toggle checked={selected.size === 0} onChange={(all) => all && setSelected(new Set())} label="Publish all pending drafts" />
          </div>} />
      )}
      {rollbackId && <Confirm title={`Roll back release ${rollbackId}?`} confirmLabel="Roll back" busy={rollback.isPending} onClose={() => setRollbackId(null)} onConfirm={() => rollback.mutate(rollbackId)} text="Every item in that release returns to the copy it replaced. This is recorded as a new release and can itself be rolled back." />}
    </Layout>
  );
}
