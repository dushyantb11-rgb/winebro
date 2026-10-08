import { useEffect, useMemo, useRef, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { api } from "../lib/api";
import { optionLists, useConfigAll } from "../lib/config";
import { Icon, Sheet } from "./ui";

/**
 * "Preview in WineBro": the real Flutter app (web build at /preview/) in a
 * phone frame. The editor's unsaved draft is sent with postMessage and
 * layered over live data inside the app; nothing is written. For dish and
 * pairing contexts the app replies with rankings computed by its own
 * engine (live rules vs draft rules), shown here as a before/after diff.
 */
export type PreviewOverrides = {
  products?: Record<string, Record<string, unknown>>;
  dishes?: Record<string, Record<string, unknown>>;
  config?: Record<string, Record<string, unknown>>;
  label?: string;
};

export type PreviewContext = {
  screen: "product" | "dish" | "pair" | "home";
  id?: string;
  mode?: string;
};

type Rank = { id: string; name: string; score: number; base: number; archetypeBonus: number; occasionBonus: number; feedbackBonus: number; foodFit: number; strategy: string; broTip?: string | null };
type RankingMsg = { dish: string; live: Rank[]; draft: Rank[]; rulesChanged: boolean };

const WIDTHS = [{ label: "Phone", w: 390, h: 760 }, { label: "Small", w: 360, h: 700 }, { label: "Tablet", w: 600, h: 820 }];

export function PreviewModal({ overrides, context, warnings = [], onClose }: {
  overrides: PreviewOverrides; context: PreviewContext; warnings?: string[]; onClose: () => void;
}) {
  const frame = useRef<HTMLIFrameElement>(null);
  const cfg = useConfigAll();
  const options = useMemo(() => optionLists(cfg.data), [cfg.data]);
  const dishes = useQuery({ queryKey: ["collection", "dishes"], queryFn: () => api.list("dishes"), enabled: context.screen !== "product" });
  const [theme, setTheme] = useState<"light" | "dark">("light");
  const [state, setState] = useState<"new" | "returning">("returning");
  const [archetype, setArchetype] = useState("");
  const [occasion, setOccasion] = useState("");
  const [dishId, setDishId] = useState(context.id ?? "");
  const [size, setSize] = useState(WIDTHS[0]);
  const [ready, setReady] = useState(false);
  const [ranking, setRanking] = useState<RankingMsg | null>(null);
  const [status, setStatus] = useState("Loading the app…");

  const screen = context.screen === "pair" && !dishId ? "pair" : context.screen;
  const ctx = useMemo(() => ({ screen, id: screen === "product" ? context.id : dishId || context.id, mode: context.mode, theme, state, archetype, occasion }), [screen, context.id, context.mode, dishId, theme, state, archetype, occasion]);

  useEffect(() => {
    const onMsg = (e: MessageEvent) => {
      if (e.origin !== window.location.origin) return;
      let data: unknown = e.data;
      if (typeof data === "string") { try { data = JSON.parse(data); } catch { return; } }
      const m = data as { type?: string } & Partial<RankingMsg> & { email?: string };
      if (m?.type === "wb-preview-loaded") setStatus("App loaded; waiting for sign-in…");
      if (m?.type === "wb-preview-ready") { setReady(true); setStatus(`Signed in as ${m.email ?? "admin"}`); }
      if (m?.type === "wb-preview-ranking") setRanking(m as RankingMsg);
    };
    window.addEventListener("message", onMsg);
    return () => window.removeEventListener("message", onMsg);
  }, []);

  // (Re)send the draft + context whenever anything changes and the app is ready.
  useEffect(() => {
    if (!ready) return;
    setRanking(null);
    frame.current?.contentWindow?.postMessage(JSON.stringify({ type: "wb-preview", overrides, context: ctx }), window.location.origin);
  }, [ready, overrides, ctx]);

  const diff = useMemo(() => {
    if (!ranking) return null;
    const liveIdx = new Map(ranking.live.map((r, i) => [r.id, i]));
    return ranking.draft.map((r, i) => {
      const was = liveIdx.get(r.id);
      const prev = ranking.live.find((x) => x.id === r.id);
      return { ...r, rank: i + 1, wasRank: was === undefined ? null : was + 1, wasScore: prev?.score ?? null };
    });
  }, [ranking]);

  return (
    <Sheet title="Preview in WineBro" onClose={onClose} wide>
      <div className="grid" style={{ gridTemplateColumns: "260px 1fr", gap: 18 }}>
        <div className="stack">
          <div className="small muted">The real app, rendered with your unsaved changes. Nothing is saved or shown to users.</div>
          <div className="field"><label>Theme</label>
            <div className="seg"><button className={theme === "light" ? "active" : ""} onClick={() => setTheme("light")}>Light</button><button className={theme === "dark" ? "active" : ""} onClick={() => setTheme("dark")}>Dark</button></div></div>
          <div className="field"><label>Device</label>
            <div className="seg">{WIDTHS.map((w) => <button key={w.label} className={size.label === w.label ? "active" : ""} onClick={() => setSize(w)}>{w.label}</button>)}</div></div>
          <div className="field"><label>User</label>
            <div className="seg"><button className={state === "new" ? "active" : ""} onClick={() => setState("new")}>New user</button><button className={state === "returning" ? "active" : ""} onClick={() => setState("returning")}>Returning (you)</button></div></div>
          {screen !== "product" && (
            <>
              <div className="field"><label>Dish</label>
                <select className="select" value={dishId} onChange={(e) => setDishId(e.target.value)}>
                  <option value="">— pick a dish —</option>
                  {(dishes.data ?? []).filter((d) => d.archived !== true).sort((a, b) => String(a.name).localeCompare(String(b.name))).map((d) => <option key={d.id} value={d.id}>{String(d.name)}</option>)}
                </select></div>
              <div className="field"><label>Test palate</label>
                <select className="select" value={archetype} onChange={(e) => setArchetype(e.target.value)}>
                  <option value="">Signed-in user's own</option>
                  {(options.archetypes ?? []).map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
                </select></div>
              <div className="field"><label>Occasion</label>
                <select className="select" value={occasion} onChange={(e) => setOccasion(e.target.value)}>
                  <option value="">None</option>
                  {(options.occasions ?? []).map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
                </select></div>
            </>
          )}
          <div className="card card-pad stack" style={{ gap: 6 }}>
            <b className="small">Publication warnings</b>
            {warnings.length === 0 ? <span className="small muted">None from the validator.</span> : warnings.map((w, i) => <span key={i} className="small" style={{ color: "var(--error)" }}>⚠ {w}</span>)}
            {ranking?.rulesChanged && <span className="small" style={{ color: "var(--warning)" }}>⚠ Pairing rules differ from live — check the ranking changes below.</span>}
          </div>
          <div className="small muted"><Icon name={ready ? "check_circle" : "hourglass_top"} className="sm" /> {status}</div>
        </div>

        <div className="stack">
          <div style={{ display: "flex", justifyContent: "center" }}>
            <div style={{ width: size.w + 24, height: size.h + 24, borderRadius: 36, background: "#111", padding: 12, boxShadow: "0 20px 50px rgba(0,0,0,.35)" }}>
              <iframe ref={frame} title="WineBro preview" src="/preview/index.html" style={{ width: size.w, height: size.h, border: 0, borderRadius: 26, background: "#fff" }} />
            </div>
          </div>
          {diff && (
            <div className="card">
              <div className="card-head"><h3>Ranking with your changes</h3><span className="small muted">from the app's own engine</span></div>
              <div className="table-wrap" style={{ maxHeight: 300 }}>
                <table className="tbl">
                  <thead><tr><th>#</th><th>Drink</th><th>Score</th><th>Was</th><th>Food fit</th><th>Palate</th><th>Bonus</th><th>Strategy</th></tr></thead>
                  <tbody>
                    {diff.map((r) => {
                      const moved = r.wasRank === null ? "new" : r.wasRank === r.rank ? "" : r.wasRank > r.rank ? `↑ from ${r.wasRank}` : `↓ from ${r.wasRank}`;
                      const changed = r.wasScore !== null && r.wasScore !== r.score;
                      return (
                        <tr key={r.id} style={moved || changed ? { background: "color-mix(in srgb, var(--warning) 12%, transparent)" } : undefined}>
                          <td className="num">{r.rank}</td><td>{r.name}</td>
                          <td className="num"><b>{r.score}</b>{changed && <span className="small muted"> ({r.wasScore})</span>}</td>
                          <td className="small">{moved}</td>
                          <td className="num">{r.foodFit}</td><td className="num">{r.base}</td>
                          <td className="num">{(r.archetypeBonus + r.occasionBonus + r.feedbackBonus).toFixed(0)}</td>
                          <td>{r.strategy}{r.broTip && <Icon name="edit_note" className="sm" />}</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>
      </div>
    </Sheet>
  );
}
