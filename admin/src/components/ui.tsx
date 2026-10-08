import React, { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from "react";
import { symbol } from "../lib/icons";

// ── Icons ────────────────────────────────────────────────────────
export function Icon({ name, fill, className = "" }: { name: string; fill?: boolean; className?: string }) {
  return <span className={`ms ${fill ? "fill" : ""} ${className}`} aria-hidden>{symbol(name)}</span>;
}

// ── Toasts ───────────────────────────────────────────────────────
type Toast = { id: number; text: string; kind: "ok" | "err" };
const ToastCtx = createContext<(text: string, kind?: Toast["kind"]) => void>(() => {});

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [list, setList] = useState<Toast[]>([]);
  const push = useCallback((text: string, kind: Toast["kind"] = "ok") => {
    const id = Date.now() + Math.random();
    setList((l) => [...l, { id, text, kind }]);
    setTimeout(() => setList((l) => l.filter((t) => t.id !== id)), kind === "err" ? 6000 : 3200);
  }, []);
  return (
    <ToastCtx.Provider value={push}>
      {children}
      <div className="toasts" role="status">
        {list.map((t) => (
          <div key={t.id} className={`toast ${t.kind}`}>
            <Icon name={t.kind === "ok" ? "check_circle" : "error"} fill />
            <span>{t.text}</span>
          </div>
        ))}
      </div>
    </ToastCtx.Provider>
  );
}
export const useToast = () => useContext(ToastCtx);

// ── Sheet / dialog ───────────────────────────────────────────────
export function Sheet({ title, onClose, children, footer, wide }: {
  title: React.ReactNode; onClose: () => void; children: React.ReactNode; footer?: React.ReactNode; wide?: boolean;
}) {
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [onClose]);
  return (
    <div className="sheet-bg" onMouseDown={(e) => e.target === e.currentTarget && onClose()}>
      <div className={`sheet ${wide ? "wide" : ""}`} role="dialog" aria-modal>
        <div className="head">
          <h2>{title}</h2>
          <button className="btn ghost icon" onClick={onClose} aria-label="Close"><Icon name="close" /></button>
        </div>
        <div className="bodyp">{children}</div>
        {footer && <div className="foot">{footer}</div>}
      </div>
    </div>
  );
}

export function Confirm({ title, text, confirmLabel = "Delete", danger = true, onConfirm, onClose, busy }: {
  title: string; text: React.ReactNode; confirmLabel?: string; danger?: boolean; onConfirm: () => void; onClose: () => void; busy?: boolean;
}) {
  return (
    <Sheet title={title} onClose={onClose} footer={<>
      <button className="btn" onClick={onClose} disabled={busy}>Cancel</button>
      <button className={`btn ${danger ? "danger" : "primary"}`} onClick={onConfirm} disabled={busy}>
        {busy ? "Working…" : confirmLabel}
      </button>
    </>}>
      <p style={{ margin: 0 }}>{text}</p>
    </Sheet>
  );
}

// ── Form fields ──────────────────────────────────────────────────
export function Field({ label, hint, error, children, right }: {
  label: React.ReactNode; hint?: React.ReactNode; error?: string; children: React.ReactNode; right?: React.ReactNode;
}) {
  return (
    <div className="field">
      <label><span>{label}</span>{right}</label>
      {children}
      {error ? <span className="err">{error}</span> : hint ? <span className="hint">{hint}</span> : null}
    </div>
  );
}

export function TextInput(props: React.InputHTMLAttributes<HTMLInputElement>) {
  return <input className="input" {...props} />;
}

export function NumberInput({ value, onChange, ...rest }: {
  value: number | undefined | null; onChange: (v: number | undefined) => void;
} & Omit<React.InputHTMLAttributes<HTMLInputElement>, "value" | "onChange">) {
  return (
    <input
      className="input" type="number" inputMode="decimal"
      value={value === undefined || value === null || Number.isNaN(value) ? "" : value}
      onChange={(e) => onChange(e.target.value === "" ? undefined : Number(e.target.value))}
      {...rest}
    />
  );
}

export function Select({ value, onChange, options, allowEmpty, ...rest }: {
  value: string | undefined; onChange: (v: string) => void; options: { value: string; label: string }[]; allowEmpty?: boolean;
} & Omit<React.SelectHTMLAttributes<HTMLSelectElement>, "value" | "onChange">) {
  const known = options.some((o) => o.value === value);
  return (
    <select className="select" value={value ?? ""} onChange={(e) => onChange(e.target.value)} {...rest}>
      {(allowEmpty || !value) && <option value="">—</option>}
      {!known && value && <option value={value}>{value} (not in list)</option>}
      {options.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
    </select>
  );
}

export function Score({ value, onChange, min = 0, max = 10, step = 0.5 }: {
  value: number | undefined; onChange: (v: number) => void; min?: number; max?: number; step?: number;
}) {
  const v = value ?? 0;
  return (
    <div className="row" style={{ gap: 12 }}>
      <input type="range" min={min} max={max} step={step} value={v} onChange={(e) => onChange(Number(e.target.value))} style={{ flex: 1 }} />
      <input className="input" type="number" min={min} max={max} step={step} value={v} style={{ width: 76 }}
        onChange={(e) => onChange(Math.min(max, Math.max(min, Number(e.target.value))))} />
    </div>
  );
}

/** Free or option-backed tags. */
export function Tags({ value, onChange, options, placeholder = "Add and press Enter" }: {
  value: string[]; onChange: (v: string[]) => void; options?: { value: string; label: string }[]; placeholder?: string;
}) {
  const [draft, setDraft] = useState("");
  const labelOf = (v: string) => options?.find((o) => o.value === v)?.label ?? v;
  const add = (v: string) => {
    const t = v.trim();
    if (!t || value.includes(t)) return;
    onChange([...value, t]);
    setDraft("");
  };
  return (
    <div className="stack" style={{ gap: 8 }}>
      <div className="chips">
        {value.map((v) => (
          <span key={v} className="chip accent">
            {labelOf(v)}
            <button type="button" onClick={() => onChange(value.filter((x) => x !== v))} aria-label={`Remove ${v}`}><Icon name="close" className="sm" /></button>
          </span>
        ))}
        {value.length === 0 && <span className="muted small">None yet</span>}
      </div>
      {options ? (
        <select className="select" value="" onChange={(e) => add(e.target.value)}>
          <option value="">Add…</option>
          {options.filter((o) => !value.includes(o.value)).map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
        </select>
      ) : (
        <input className="input" value={draft} placeholder={placeholder} onChange={(e) => setDraft(e.target.value)}
          onKeyDown={(e) => { if (e.key === "Enter" || e.key === ",") { e.preventDefault(); add(draft); } }}
          onBlur={() => draft && add(draft)} />
      )}
    </div>
  );
}

export function Toggle({ checked, onChange, label }: { checked: boolean; onChange: (v: boolean) => void; label: React.ReactNode }) {
  return (
    <label className="check">
      <input type="checkbox" checked={checked} onChange={(e) => onChange(e.target.checked)} />
      <span>{label}</span>
    </label>
  );
}

/** Icon picker: a select with a live glyph. */
export function IconPicker({ value, onChange, names }: { value: string | undefined; onChange: (v: string) => void; names: readonly string[] }) {
  return (
    <div className="row" style={{ flexWrap: "nowrap" }}>
      <span className="btn icon" style={{ pointerEvents: "none" }}><Icon name={value ?? ""} /></span>
      <select className="select" value={value ?? ""} onChange={(e) => onChange(e.target.value)}>
        <option value="">—</option>
        {names.map((n) => <option key={n} value={n}>{n}</option>)}
      </select>
    </div>
  );
}

// ── Misc ─────────────────────────────────────────────────────────
export function Empty({ icon = "inbox", title, text, action }: { icon?: string; title: string; text?: string; action?: React.ReactNode }) {
  return (
    <div className="empty">
      <Icon name={icon} />
      <b>{title}</b>
      {text && <span className="small">{text}</span>}
      {action}
    </div>
  );
}

export function Skeleton({ rows = 6 }: { rows?: number }) {
  return <div className="stack card card-pad">{Array.from({ length: rows }).map((_, i) => <div key={i} className="skeleton" style={{ width: `${70 + ((i * 13) % 30)}%` }} />)}</div>;
}

export function Tabs<T extends string>({ value, onChange, tabs }: { value: T; onChange: (t: T) => void; tabs: { id: T; label: string }[] }) {
  return (
    <div className="tabs">
      {tabs.map((t) => <button key={t.id} className={t.id === value ? "active" : ""} onClick={() => onChange(t.id)}>{t.label}</button>)}
    </div>
  );
}

/** Keeps a draft in sync with a loaded value and tracks dirtiness. */
export function useDraft<T>(source: T | undefined) {
  const [draft, setDraft] = useState<T | undefined>(source);
  const loaded = useRef<string>("");
  useEffect(() => {
    const s = JSON.stringify(source ?? null);
    if (s !== loaded.current) {
      loaded.current = s;
      setDraft(source ? (JSON.parse(s) as T) : undefined);
    }
  }, [source]);
  const dirty = useMemo(() => JSON.stringify(draft ?? null) !== loaded.current, [draft]);
  const reset = () => setDraft(loaded.current ? (JSON.parse(loaded.current) as T) : undefined);
  return { draft, setDraft, dirty, reset };
}

export function useTheme() {
  const [theme, setTheme] = useState<string>(() => { try { return localStorage.getItem("theme") ?? "auto"; } catch { return "auto"; } });
  useEffect(() => {
    if (theme === "auto") document.documentElement.removeAttribute("data-theme");
    else document.documentElement.setAttribute("data-theme", theme);
    try { localStorage.setItem("theme", theme); } catch { /* ignore */ }
  }, [theme]);
  return { theme, setTheme };
}
