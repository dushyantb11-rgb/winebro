import { useMemo, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useParams } from "react-router-dom";
import { api, Doc } from "../lib/api";
import { CONFIG_DOCS, optionLists, useConfigAll } from "../lib/config";
import { fmtDate } from "../lib/format";
import { Layout } from "../components/Layout";
import { PreviewModal } from "../components/PreviewModal";
import { Confirm, Empty, Icon, Sheet, Skeleton, Tabs, useDraft, useToast } from "../components/ui";
import { RuleForm } from "./RuleForms";

type Content = Record<string, unknown>;

function stripMeta(d: Doc | undefined | null): Content | undefined {
  if (!d) return undefined;
  const { id, version, source, updatedAt, updatedBy, releaseId, readOnly, draft, hasDraft, _draft, ...rest } = d as Doc & Record<string, unknown>;
  void id; void version; void source; void updatedAt; void updatedBy; void releaseId; void readOnly; void draft; void hasDraft; void _draft;
  return rest;
}

export default function RuleEditor() {
  const { doc = "" } = useParams();
  const meta = CONFIG_DOCS.find((c) => c.id === doc);
  const qc = useQueryClient();
  const toast = useToast();
  const q = useQuery({ queryKey: ["configdoc", doc], queryFn: () => api.config(doc), enabled: !!meta });
  const all = useConfigAll();
  const options = useMemo(() => optionLists(all.data), [all.data]);
  // Edit the draft when one exists, otherwise the live document.
  const source = useMemo(() => stripMeta(q.data?.draft ?? q.data), [q.data]);
  const { draft, setDraft, dirty, reset } = useDraft<Content>(source);
  const [tab, setTab] = useState<"form" | "json" | "history">("form");
  const [jsonText, setJsonText] = useState<string | null>(null);
  const [jsonErr, setJsonErr] = useState<string | undefined>();
  const [restoreV, setRestoreV] = useState<string | null>(null);
  const [preview, setPreview] = useState<Doc | null>(null);
  const [showPhone, setShowPhone] = useState(false);
  const [confirmDiscard, setConfirmDiscard] = useState(false);
  const history = useQuery({ queryKey: ["confighistory", doc], queryFn: () => api.configHistory(doc), enabled: tab === "history" });
  const hasDraft = !!q.data?.draft;
  const readOnly = q.data?.readOnly === true;

  const invalidate = () => {
    void qc.invalidateQueries({ queryKey: ["config"] });
    void qc.invalidateQueries({ queryKey: ["configdoc", doc] });
    void qc.invalidateQueries({ queryKey: ["stats"] });
    void qc.invalidateQueries({ queryKey: ["drafts"] });
    void qc.invalidateQueries({ queryKey: ["confighistory", doc] });
  };
  const save = useMutation({
    mutationFn: ({ content, target }: { content: Content; target: "draft" | "live" }) => api.saveConfig(doc, { ...content, version: q.data?.version }, target),
    onSuccess: (saved, vars) => { toast(vars.target === "live" ? `Published as version ${saved.version}. The app uses it from now on.` : "Saved as draft (not live yet)"); invalidate(); },
    onError: (e) => toast(e instanceof Error ? e.message : "Save failed", "err"),
  });
  const discard = useMutation({
    mutationFn: () => api.discardDraft("config", doc),
    onSuccess: () => { toast("Draft discarded"); setConfirmDiscard(false); invalidate(); },
    onError: (e) => toast(e instanceof Error ? e.message : "Could not discard", "err"),
  });
  const restore = useMutation({
    mutationFn: (v: string) => api.restoreConfig(doc, v),
    onSuccess: (saved) => { toast(`Restored as version ${saved.version}`); invalidate(); setRestoreV(null); },
    onError: (e) => toast(e instanceof Error ? e.message : "Restore failed", "err"),
  });

  if (!meta) return <Layout title="Not found"><Empty title="Unknown rules document" /></Layout>;
  if (q.isLoading || !draft) return <Layout title={meta.title}><Skeleton /></Layout>;

  const openJson = () => { setJsonText(JSON.stringify(draft, null, 2)); setJsonErr(undefined); setTab("json"); };
  const canSave = dirty && !jsonErr && !readOnly;
  const previewOverrides = { config: { [doc]: draft }, label: `Draft rules: ${meta.title}` };

  return (
    <Layout title={meta.title} crumbs={`Rules · live v${Number(q.data?.version ?? 0)} · ${fmtDate(q.data?.updatedAt)}${hasDraft ? " · DRAFT" : ""}`} actions={<>
      {(doc === "pairingRules" || doc === "home" || doc === "categories" || doc === "occasions" || doc === "archetypes") && (
        <button className="btn" onClick={() => setShowPhone(true)}><Icon name="smartphone" className="sm" />Preview in WineBro</button>
      )}
      {dirty && <button className="btn" onClick={reset}>Discard changes</button>}
      {!readOnly && <button className="btn primary" disabled={!canSave || save.isPending} onClick={() => save.mutate({ content: draft, target: "draft" })}><Icon name="save" className="sm" />Save draft</button>}
      {!readOnly && <button className="btn" disabled={save.isPending || !!jsonErr || (!dirty && !hasDraft)} onClick={() => save.mutate({ content: draft, target: "live" })}><Icon name="rocket_launch" className="sm" />Publish now</button>}
    </>}>
      <div className="small muted">{meta.blurb}</div>
      {readOnly && <div className="chip info"><Icon name="lock" className="sm" />Reference only: the app does not read this document yet, so it cannot be edited here.</div>}
      {hasDraft && <div className="chip warn"><Icon name="edit_note" className="sm" />Editing a draft; the live version stays in force until you publish. <button className="btn ghost sm" onClick={() => setConfirmDiscard(true)}>Discard draft</button></div>}
      <Tabs value={tab} onChange={(t) => { if (t === "json") openJson(); else setTab(t); }} tabs={[{ id: "form", label: "Edit" }, { id: "json", label: "JSON" }, { id: "history", label: "History" }]} />

      {tab === "form" && (readOnly ? <pre className="mono card card-pad" style={{ whiteSpace: "pre-wrap" }}>{JSON.stringify(draft, null, 2)}</pre> : <RuleForm doc={doc} value={draft} onChange={setDraft} options={options} all={all.data} />)}

      {tab === "json" && (
        <div className="card card-pad stack">
          <div className="small muted">The raw document the app reads. Edit carefully; invalid JSON cannot be saved.</div>
          <textarea className="textarea json" style={{ minHeight: 480 }} value={jsonText ?? ""} readOnly={readOnly} onChange={(e) => { setJsonText(e.target.value); try { setDraft(JSON.parse(e.target.value)); setJsonErr(undefined); } catch (x) { setJsonErr((x as Error).message); } }} />
          {jsonErr && <span className="small" style={{ color: "var(--error)" }}>{jsonErr}</span>}
        </div>
      )}

      {tab === "history" && (
        history.isLoading ? <Skeleton /> : !history.data?.length ? <Empty icon="history" title="No earlier versions yet" text="Each publish keeps the previous version here." /> : (
          <div className="card table-wrap">
            <table className="tbl">
              <thead><tr><th>Version</th><th>Saved by</th><th>Was live until</th><th /></tr></thead>
              <tbody>
                {history.data.map((h) => (
                  <tr key={h.id}>
                    <td><span className="pill-num">v{h.id}</span></td>
                    <td>{String(h.updatedBy ?? (h.source === "code-export" ? "Initial export" : h.source ?? ""))}</td>
                    <td>{fmtDate(h.archivedAt)}</td>
                    <td className="row end">
                      <button className="btn sm" onClick={() => setPreview(h)}><Icon name="visibility" className="sm" />View</button>
                      {!readOnly && <button className="btn sm" onClick={() => setRestoreV(h.id)}><Icon name="restore" className="sm" />Restore</button>}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )
      )}

      {dirty && !readOnly && (
        <div className="sticky-actions">
          <span className="small muted" style={{ marginRight: "auto", alignSelf: "center" }}>Unsaved changes</span>
          <button className="btn" onClick={reset}>Discard changes</button>
          <button className="btn primary" disabled={!canSave || save.isPending} onClick={() => save.mutate({ content: draft, target: "draft" })}><Icon name="save" className="sm" />Save draft</button>
          <button className="btn" disabled={save.isPending || !!jsonErr} onClick={() => save.mutate({ content: draft, target: "live" })}><Icon name="rocket_launch" className="sm" />Publish now</button>
        </div>
      )}

      {restoreV && <Confirm title={`Restore version ${restoreV}?`} danger={false} confirmLabel="Restore" text="The current version is kept in history; the restored content becomes a new live version at once." onClose={() => setRestoreV(null)} onConfirm={() => restore.mutate(restoreV)} busy={restore.isPending} />}
      {confirmDiscard && <Confirm title="Discard the draft?" confirmLabel="Discard" text="The saved draft is removed; the live version is unchanged." onClose={() => setConfirmDiscard(false)} onConfirm={() => discard.mutate()} busy={discard.isPending} />}
      {preview && <Sheet title={`Version ${preview.id}`} onClose={() => setPreview(null)} wide><pre className="mono" style={{ whiteSpace: "pre-wrap", margin: 0 }}>{JSON.stringify(stripMeta(preview), null, 2)}</pre></Sheet>}
      {showPhone && <PreviewModal overrides={previewOverrides} context={{ screen: doc === "home" ? "home" : "pair" }} onClose={() => setShowPhone(false)} />}
    </Layout>
  );
}
