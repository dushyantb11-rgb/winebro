import { useMemo, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useParams } from "react-router-dom";
import { api, Doc } from "../lib/api";
import { CONFIG_DOCS, optionLists, useConfigAll } from "../lib/config";
import { fmtDate } from "../lib/format";
import { Layout } from "../components/Layout";
import { Confirm, Empty, Icon, Sheet, Skeleton, Tabs, useDraft, useToast } from "../components/ui";
import { RuleForm } from "./RuleForms";
import { TryPairing } from "./TryPairing";

type Content = Record<string, unknown>;

function stripMeta(d: Doc | undefined): Content | undefined {
  if (!d) return undefined;
  const { id, version, source, updatedAt, ...rest } = d;
  void id; void version; void source; void updatedAt;
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
  const { draft, setDraft, dirty, reset } = useDraft<Content>(stripMeta(q.data));
  const [tab, setTab] = useState<"form" | "json" | "history" | "try">("form");
  const [jsonText, setJsonText] = useState<string | null>(null);
  const [jsonErr, setJsonErr] = useState<string | undefined>();
  const [restoreV, setRestoreV] = useState<string | null>(null);
  const [preview, setPreview] = useState<Doc | null>(null);
  const history = useQuery({ queryKey: ["confighistory", doc], queryFn: () => api.configHistory(doc), enabled: tab === "history" });

  const save = useMutation({
    mutationFn: (content: Content) => api.saveConfig(doc, { ...content, version: q.data?.version }),
    onSuccess: (saved) => {
      toast(`Saved as version ${saved.version}. The app uses it from now on.`);
      qc.setQueryData(["configdoc", doc], saved);
      void qc.invalidateQueries({ queryKey: ["config"] });
      void qc.invalidateQueries({ queryKey: ["stats"] });
      void qc.invalidateQueries({ queryKey: ["confighistory", doc] });
    },
    onError: (e) => toast(e instanceof Error ? e.message : "Save failed", "err"),
  });
  const restore = useMutation({
    mutationFn: (v: string) => api.restoreConfig(doc, v),
    onSuccess: (saved) => {
      toast(`Restored as version ${saved.version}`);
      qc.setQueryData(["configdoc", doc], saved);
      void qc.invalidateQueries({ queryKey: ["config"] });
      void qc.invalidateQueries({ queryKey: ["confighistory", doc] });
      setRestoreV(null);
    },
    onError: (e) => toast(e instanceof Error ? e.message : "Restore failed", "err"),
  });

  if (!meta) return <Layout title="Not found"><Empty title="Unknown rules document" /></Layout>;
  if (q.isLoading || !draft) return <Layout title={meta.title}><Skeleton /></Layout>;

  const openJson = () => { setJsonText(JSON.stringify(draft, null, 2)); setJsonErr(undefined); setTab("json"); };

  return (
    <Layout title={meta.title} crumbs={`Rules · version ${Number(q.data?.version ?? 0)} · ${fmtDate(q.data?.updatedAt)}`} actions={<>
      {dirty && <button className="btn" onClick={reset}>Discard</button>}
      <button className="btn primary" disabled={!dirty || save.isPending || !!jsonErr} onClick={() => save.mutate(draft)}><Icon name="save" className="sm" />{save.isPending ? "Saving…" : "Save as new version"}</button>
    </>}>
      <div className="small muted">{meta.blurb}</div>
      <Tabs value={tab} onChange={(t) => { if (t === "json") openJson(); else setTab(t); }} tabs={[
        { id: "form", label: "Edit" },
        ...(doc === "pairingRules" ? [{ id: "try" as const, label: "Try a pairing" }] : []),
        { id: "json", label: "JSON" },
        { id: "history", label: "History" },
      ]} />

      {tab === "form" && <RuleForm doc={doc} value={draft} onChange={setDraft} options={options} all={all.data} />}

      {tab === "try" && <TryPairing rules={draft} />}

      {tab === "json" && (
        <div className="card card-pad stack">
          <div className="small muted">The raw document the app reads. Edit carefully; invalid JSON cannot be saved.</div>
          <textarea className="textarea json" style={{ minHeight: 480 }} value={jsonText ?? ""} onChange={(e) => {
            setJsonText(e.target.value);
            try { setDraft(JSON.parse(e.target.value)); setJsonErr(undefined); } catch (x) { setJsonErr((x as Error).message); }
          }} />
          {jsonErr && <span className="err small" style={{ color: "var(--error)" }}>{jsonErr}</span>}
        </div>
      )}

      {tab === "history" && (
        history.isLoading ? <Skeleton /> : !history.data?.length ? <Empty icon="history" title="No earlier versions yet" text="Each save keeps the previous version here." /> : (
          <div className="card table-wrap">
            <table className="tbl">
              <thead><tr><th>Version</th><th>Saved by</th><th>Was live until</th><th /></tr></thead>
              <tbody>
                {history.data.map((h) => (
                  <tr key={h.id}>
                    <td><span className="pill-num">v{h.id}</span></td>
                    <td>{h.source === "admin" ? "Console" : h.source === "code-export" ? "Initial export" : String(h.source ?? "")}</td>
                    <td>{fmtDate(h.archivedAt)}</td>
                    <td className="row end">
                      <button className="btn sm" onClick={() => setPreview(h)}><Icon name="visibility" className="sm" />View</button>
                      <button className="btn sm" onClick={() => setRestoreV(h.id)}><Icon name="restore" className="sm" />Restore</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )
      )}

      {dirty && (
        <div className="sticky-actions">
          <span className="small muted" style={{ marginRight: "auto", alignSelf: "center" }}>Unsaved changes</span>
          <button className="btn" onClick={reset}>Discard</button>
          <button className="btn primary" disabled={save.isPending || !!jsonErr} onClick={() => save.mutate(draft)}><Icon name="save" className="sm" />Save as new version</button>
        </div>
      )}

      {restoreV && <Confirm title={`Restore version ${restoreV}?`} danger={false} confirmLabel="Restore" text="The current version is kept in history; the restored content becomes a new version and the app uses it right away." onClose={() => setRestoreV(null)} onConfirm={() => restore.mutate(restoreV)} busy={restore.isPending} />}
      {preview && (
        <Sheet title={`Version ${preview.id}`} onClose={() => setPreview(null)} wide>
          <pre className="mono" style={{ whiteSpace: "pre-wrap", margin: 0 }}>{JSON.stringify(stripMeta(preview), null, 2)}</pre>
        </Sheet>
      )}
    </Layout>
  );
}
