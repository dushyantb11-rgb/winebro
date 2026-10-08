import { useMemo, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useNavigate, useParams } from "react-router-dom";
import { api, Doc } from "../lib/api";
import { byId, Field as FieldSpec, getAny, setAny, SCORE_KEYS } from "../lib/schema";
import { optionLists, useConfigAll } from "../lib/config";
import { fmtDate, slug } from "../lib/format";
import { Layout } from "../components/Layout";
import { ImageUpload } from "../components/ImageUpload";
import { Confirm, Field, Icon, NumberInput, Score, Select, Skeleton, Tags, TextInput, Toggle, useDraft, useToast, Empty } from "../components/ui";

type Row = Record<string, unknown>;

export default function Editor() {
  const { collection = "", id = "" } = useParams();
  const isNew = id === "new";
  const spec = byId(collection);
  const nav = useNavigate();
  const qc = useQueryClient();
  const toast = useToast();
  const cfg = useConfigAll();
  const options = useMemo(() => optionLists(cfg.data), [cfg.data]);
  const q = useQuery({ queryKey: ["doc", collection, id], queryFn: () => api.get(collection, id), enabled: !!spec && !isNew });
  const products = useQuery({ queryKey: ["collection", "products"], queryFn: () => api.list("products"), enabled: collection === "dishes" });
  const blank = useMemo<Row>(() => (spec ? blankFor(spec.id) : {}), [spec]);
  const { draft, setDraft, dirty, reset } = useDraft<Row>(isNew ? blank : (q.data as Row | undefined));
  const [confirmDelete, setConfirmDelete] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const save = useMutation({
    mutationFn: async (doc: Row) => (isNew ? api.create(collection, doc as Doc) : api.update(collection, id, doc as Doc)),
    onSuccess: (saved) => {
      toast(`${spec?.singular ?? "Item"} saved`);
      void qc.invalidateQueries({ queryKey: ["collection", collection] });
      void qc.invalidateQueries({ queryKey: ["stats"] });
      qc.setQueryData(["doc", collection, saved.id], saved);
      if (isNew) nav(`/c/${collection}/${encodeURIComponent(saved.id)}`, { replace: true });
    },
    onError: (e) => toast(e instanceof Error ? e.message : "Save failed", "err"),
  });
  const del = useMutation({
    mutationFn: () => api.remove(collection, id),
    onSuccess: () => {
      toast(`${spec?.singular ?? "Item"} deleted`);
      void qc.invalidateQueries({ queryKey: ["collection", collection] });
      nav(`/c/${collection}`);
    },
    onError: (e) => toast(e instanceof Error ? e.message : "Delete failed", "err"),
  });

  if (!spec) return <Layout title="Not found"><Empty title="Unknown collection" /></Layout>;
  if (!isNew && q.isLoading) return <Layout title={spec.title}><Skeleton /></Layout>;
  if (!isNew && q.error) return <Layout title={spec.title}><Empty icon="error" title="Could not load" text={String(q.error)} /></Layout>;
  if (!draft) return <Layout title={spec.title}><Skeleton /></Layout>;

  const set = (key: string, value: unknown) => setDraft((d) => { const n = structuredClone(d ?? {}); setAny(n, key, value); return n; });
  const sections = groupBy(spec.fields.filter((f) => f.type !== "readonly" || getAny(draft, f.key) !== undefined), (f) => f.section ?? "Details");
  const title = isNew ? `New ${spec.singular}` : String(draft.name ?? draft.productName ?? draft.id ?? "");
  const readOnly = !spec.editable;

  const submit = () => {
    const errs: Record<string, string> = {};
    for (const f of spec.fields) {
      const v = getAny(draft, f.key);
      if (f.required && (v === undefined || v === null || String(v).trim() === "")) errs[f.key] = "Required";
      if (f.key === "id" && typeof v === "string" && v && !/^[a-z0-9][a-z0-9-]*$/.test(v)) errs[f.key] = "Lower-case letters, digits and dashes only";
      if ((f.type === "number" || f.type === "score") && typeof v === "number") {
        if (f.min !== undefined && v < f.min) errs[f.key] = `At least ${f.min}`;
        if (f.max !== undefined && v > f.max) errs[f.key] = `At most ${f.max}`;
      }
    }
    setErrors(errs);
    if (Object.keys(errs).length) return toast("Please fix the highlighted fields", "err");
    save.mutate(draft);
  };

  return (
    <Layout
      title={title}
      crumbs={`${spec.title}${isNew ? "" : ` · ${draft.id ?? ""}`}`}
      actions={<>
        {!isNew && spec.deletable && <button className="btn danger" onClick={() => setConfirmDelete(true)}><Icon name="delete" className="sm" />Delete</button>}
        {!readOnly && dirty && <button className="btn" onClick={reset}>Discard</button>}
        {!readOnly && <button className="btn primary" disabled={!dirty && !isNew || save.isPending} onClick={submit}><Icon name="save" className="sm" />{save.isPending ? "Saving…" : "Save"}</button>}
      </>}
    >
      {readOnly && <div className="chip info"><Icon name="lock" className="sm" />Read-only: this data is computed or belongs to users. You can export or delete rows.</div>}
      {Object.entries(sections).map(([section, fields]) => (
        <div key={section} className="card">
          <div className="card-head"><h3>{section}</h3>{section.startsWith("Taste") && <span className="small muted">0 = none · 10 = very strong</span>}</div>
          <div className="card-pad grid form">
            {fields.map((f) => (
              <FieldEditor key={f.key} f={f} draft={draft} set={set} options={options} readOnly={readOnly || (f.key === "id" && !isNew)}
                error={errors[f.key]} spec={spec} products={products.data ?? []} />
            ))}
          </div>
        </div>
      ))}
      {!readOnly && (
        <div className="sticky-actions">
          <span className="small muted" style={{ marginRight: "auto", alignSelf: "center" }}>{dirty ? "Unsaved changes" : isNew ? "Fill in and save" : `Updated ${fmtDate(draft.updatedAt)}`}</span>
          {dirty && <button className="btn" onClick={reset}>Discard</button>}
          <button className="btn primary" disabled={(!dirty && !isNew) || save.isPending} onClick={submit}><Icon name="save" className="sm" />{save.isPending ? "Saving…" : "Save"}</button>
        </div>
      )}
      {confirmDelete && (
        <Confirm title={`Delete this ${spec.singular}?`} text={<>“{title}” will be removed from the app for everyone. This cannot be undone.</>}
          onClose={() => setConfirmDelete(false)} onConfirm={() => del.mutate()} busy={del.isPending} />
      )}
    </Layout>
  );
}

function FieldEditor({ f, draft, set, options, readOnly, error, spec, products }: {
  f: FieldSpec; draft: Row; set: (k: string, v: unknown) => void; options: Record<string, { value: string; label: string }[]>;
  readOnly: boolean; error?: string; spec: NonNullable<ReturnType<typeof byId>>; products: Doc[];
}) {
  const v = getAny(draft, f.key);
  const span = f.span ? "span2" : "";
  const label = <>{f.label}{f.required && <span style={{ color: "var(--error)" }}> *</span>}</>;
  if (readOnly || f.type === "readonly") {
    const text = v === undefined || v === null ? "—" : f.key.endsWith("At") ? fmtDate(v) : Array.isArray(v) ? v.join(", ") : typeof v === "object" ? JSON.stringify(v, null, 2) : String(v);
    return <div className={`field ${f.type === "json" ? "span2" : span}`}><label>{f.label}</label>{f.type === "json" ? <pre className="mono card card-pad" style={{ margin: 0, whiteSpace: "pre-wrap", maxHeight: 320, overflow: "auto" }}>{text}</pre> : <div style={{ padding: "6px 0" }}>{text}</div>}</div>;
  }
  switch (f.type) {
    case "text":
      return <div className={span}><Field label={label} hint={f.hint} error={error}><TextInput value={String(v ?? "")} onChange={(e) => set(f.key, e.target.value)}
        onBlur={f.key === "id" ? (e) => set("id", slug(e.target.value)) : undefined} /></Field></div>;
    case "textarea":
      return <div className={span || "span2"}><Field label={label} hint={f.hint} error={error}><textarea className="textarea" value={String(v ?? "")} onChange={(e) => set(f.key, e.target.value)} /></Field></div>;
    case "number":
      return <div className={span}><Field label={label} hint={f.hint} error={error}><NumberInput value={typeof v === "number" ? v : undefined} min={f.min} max={f.max} step={f.step} onChange={(n) => set(f.key, n)} /></Field></div>;
    case "score":
      return <div className={span}><Field label={label} right={<b>{typeof v === "number" ? v : 0}</b>} error={error}><Score value={typeof v === "number" ? v : undefined} min={f.min} max={f.max} step={f.step} onChange={(n) => set(f.key, n)} /></Field></div>;
    case "boolean":
      return <div className={span}><Field label={label} hint={f.hint}><Toggle checked={v === true} onChange={(b) => set(f.key, b)} label={v === true ? "Yes" : "No"} /></Field></div>;
    case "select": {
      const opts = typeof f.options === "string" ? options[f.options] ?? [] : (f.options ?? []).map((o) => ({ value: o, label: o || "—" }));
      return <div className={span}><Field label={label} hint={f.hint} error={error}><Select value={v === undefined || v === null ? undefined : String(v)} options={opts.filter((o) => o.value !== "")} allowEmpty={!f.required} onChange={(s) => set(f.key, s || undefined)} /></Field></div>;
    }
    case "tags":
      return <div className={span || "span2"}><Field label={label} hint={f.hint}><Tags value={Array.isArray(v) ? v.map(String) : []} options={typeof f.options === "string" ? options[f.options] : undefined} onChange={(t) => set(f.key, t)} /></Field></div>;
    case "image": {
      const fallback = spec.imageFallback?.(draft);
      const credit = [getAny(draft, "openData.bottlePhoto.author"), getAny(draft, "openData.bottlePhoto.licence"), getAny(draft, "openData.photo.author"), getAny(draft, "openData.photo.licence")].filter(Boolean).join(" · ");
      return <div className="span2"><ImageUpload value={typeof v === "string" ? v : undefined} fallback={fallback} credit={credit} folder={spec.id === "dishes" ? "dishes" : "products"} id={String(draft.id ?? "")} onChange={(url) => set(f.key, url)} /></div>;
    }
    case "pairings":
      return <div className="span2"><PairingsEditor value={Array.isArray(v) ? (v as Row[]) : []} onChange={(p) => set(f.key, p)} products={products} options={options} /></div>;
    case "json":
      return <div className="span2"><JsonEditor label={f.label} value={v} onChange={(j) => set(f.key, j)} /></div>;
    default:
      return null;
  }
}

function PairingsEditor({ value, onChange, products, options }: {
  value: Row[]; onChange: (v: Row[]) => void; products: Doc[]; options: Record<string, { value: string; label: string }[]>;
}) {
  const prodOpts = useMemo(() => products.map((p) => ({ value: p.id, label: `${p.name} (${p.category})` })).sort((a, b) => a.label.localeCompare(b.label)), [products]);
  const update = (i: number, patch: Row) => onChange(value.map((p, j) => (j === i ? { ...p, ...patch } : p)));
  return (
    <div className="stack">
      <div className="row between"><span className="small muted">Hand-written pairings win over the computed ones and show the Bro tip as written here.</span>
        <button type="button" className="btn sm" onClick={() => onChange([...value, { productId: prodOpts[0]?.value ?? "", strategy: "complement", broTip: "", score: 80 }])}><Icon name="add" className="sm" />Add pairing</button></div>
      {value.map((p, i) => (
        <div key={i} className="rule">
          <div className="grid form" style={{ gap: 10 }}>
            <Field label="Drink"><Select value={String(p.productId ?? "")} options={prodOpts} onChange={(s) => update(i, { productId: s })} /></Field>
            <Field label="Strategy"><Select value={String(p.strategy ?? "complement")} options={options.strategies?.length ? options.strategies : [{ value: "complement", label: "Complement" }, { value: "contrast", label: "Contrast" }]} onChange={(s) => update(i, { strategy: s })} /></Field>
            <Field label="Match score" right={<b>{Number(p.score ?? 0)}</b>}><Score value={Number(p.score ?? 0)} min={40} max={99} step={1} onChange={(n) => update(i, { score: n })} /></Field>
            <div className="span2"><Field label="Bro tip"><textarea className="textarea" style={{ minHeight: 64 }} value={String(p.broTip ?? "")} onChange={(e) => update(i, { broTip: e.target.value })} /></Field></div>
          </div>
          <button type="button" className="btn ghost icon" onClick={() => onChange(value.filter((_, j) => j !== i))} aria-label="Remove"><Icon name="delete" /></button>
        </div>
      ))}
      {value.length === 0 && <div className="small muted">No hand-written pairings. The app computes matches from the pairing rules.</div>}
    </div>
  );
}

export function JsonEditor({ label, value, onChange }: { label: string; value: unknown; onChange: (v: unknown) => void }) {
  const [text, setText] = useState(() => JSON.stringify(value ?? {}, null, 2));
  const [err, setErr] = useState<string | undefined>();
  const [open, setOpen] = useState(false);
  return (
    <div className="field">
      <label><span>{label}</span><button type="button" className="btn ghost sm" onClick={() => setOpen((o) => !o)}>{open ? "Hide" : "Edit as JSON"}</button></label>
      {open ? (
        <>
          <textarea className="textarea json" value={text} onChange={(e) => {
            setText(e.target.value);
            try { onChange(JSON.parse(e.target.value)); setErr(undefined); } catch (x) { setErr((x as Error).message); }
          }} />
          {err && <span className="err">{err}</span>}
        </>
      ) : (
        <pre className="mono card card-pad" style={{ margin: 0, whiteSpace: "pre-wrap", maxHeight: 220, overflow: "auto" }}>{JSON.stringify(value ?? {}, null, 2).slice(0, 4000)}</pre>
      )}
    </div>
  );
}

function blankFor(collection: string): Row {
  if (collection === "products") {
    const r: Row = { id: "", name: "", category: "", subcategory: "", region: "", price: 0, tastingNotes: "", aromas: [], archetypeTags: [], verified: false };
    for (const k of SCORE_KEYS) r[k] = 5;
    return r;
  }
  if (collection === "dishes") return { id: "", name: "", category: "", description: "", foodProperties: [], pairings: [], verified: false };
  return { id: "" };
}

function groupBy<T>(list: T[], key: (t: T) => string): Record<string, T[]> {
  const out: Record<string, T[]> = {};
  for (const x of list) (out[key(x)] ??= []).push(x);
  return out;
}
