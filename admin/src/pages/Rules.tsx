import { Link } from "react-router-dom";
import { useConfigAll, CONFIG_DOCS } from "../lib/config";
import { fmtDate } from "../lib/format";
import { Layout } from "../components/Layout";
import { Icon, Skeleton } from "../components/ui";

export default function Rules() {
  const cfg = useConfigAll();
  return (
    <Layout title="Rules and lists" crumbs="Rules">
      <div className="small muted">
        Everything the app uses to score, classify and label. Each document keeps a version history, so you can restore an earlier version.
        The app picks up a saved change the next time it opens a screen; it never needs a new release for this.
      </div>
      {cfg.isLoading ? <Skeleton /> : (
        <div className="grid cards">
          {CONFIG_DOCS.map((c) => {
            const d = cfg.data?.[c.id];
            return (
              <Link key={c.id} to={`/rules/${c.id}`} className="card item-card">
                <div className="body" style={{ padding: 18, gap: 8 }}>
                  <div className="row between">
                    <span className="btn icon" style={{ pointerEvents: "none", background: "color-mix(in srgb, var(--paprika) 12%, transparent)", borderColor: "transparent", color: "var(--accent)" }}><Icon name={c.icon} fill /></span>
                    <span className="pill-num">v{Number(d?.version ?? 0)}</span>
                  </div>
                  <div className="name">{c.title}</div>
                  <div className="small muted" style={{ whiteSpace: "normal" }}>{c.blurb}</div>
                  <div className="small muted">{d?.updatedAt ? `Changed ${fmtDate(d.updatedAt)}` : "Not loaded"}</div>
                </div>
              </Link>
            );
          })}
        </div>
      )}
    </Layout>
  );
}
