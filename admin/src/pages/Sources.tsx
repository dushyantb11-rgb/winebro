import { useQuery } from "@tanstack/react-query";
import { Link } from "react-router-dom";
import { api, SourceCard } from "../lib/api";
import { Layout } from "../components/Layout";
import { Icon, Skeleton } from "../components/ui";

const ICONS: Record<string, string> = { grapeminds: "wine_bar", openFoodFacts: "inventory_2", wikidata: "hub", bottlePhoto: "photo_library", xwines: "dataset", bjcpStyle: "sports_bar", indianFood101: "restaurant", spiritsdatabase: "liquor" };

export default function Sources() {
  const q = useQuery({ queryKey: ["sources"], queryFn: api.sources });
  return (
    <Layout title="Data Cellar" crumbs="Where WineBro's facts come from">
      <div className="small muted">Every outside source the catalogue draws on, with what it provides, how many of our records use it and the licence posture. Connected sources open their own dashboard.</div>
      {q.isLoading ? <Skeleton /> : (
        <div className="grid cards" style={{ gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))" }}>
          {(q.data?.sources ?? []).map((s) => <Card key={s.id} s={s} totals={q.data!.totals} />)}
          <div className="card item-card" style={{ opacity: 0.7, cursor: "default", borderStyle: "dashed" }}>
            <div className="body" style={{ padding: 18, gap: 8 }}>
              <span className="btn icon" style={{ pointerEvents: "none", borderColor: "transparent" }}><Icon name="add" /></span>
              <div className="name">Add a source</div>
              <div className="small muted" style={{ whiteSpace: "normal" }}>Producer feeds, GS1 India, retailer lists — each arrives as its own card with a licence record.</div>
            </div>
          </div>
        </div>
      )}
    </Layout>
  );
}

function Card({ s, totals }: { s: SourceCard; totals: { products: number; dishes: number } }) {
  const tone = s.status === "connected" ? "ok" : s.status === "unusable" ? "err" : "info";
  const label = s.status === "connected" ? "Connected" : s.status === "unusable" ? "Not usable" : "Linked";
  const denom = s.id === "indianFood101" ? totals.dishes : totals.products;
  const body = (
    <div className="body" style={{ padding: 18, gap: 8 }}>
      <div className="row between">
        <span className="btn icon" style={{ pointerEvents: "none", background: "color-mix(in srgb, var(--paprika) 12%, transparent)", borderColor: "transparent", color: "var(--accent)" }}><Icon name={ICONS[s.id] ?? "database"} fill /></span>
        <span className={`chip ${tone}`}>{label}</span>
      </div>
      <div className="name">{s.name}</div>
      <div className="small muted" style={{ whiteSpace: "normal" }}>{s.provides}</div>
      <div className="row between" style={{ marginTop: 4 }}>
        <span className="small"><b>{s.records}</b> of {denom} {s.id === "indianFood101" ? "dishes" : "drinks"}</span>
        {s.extra && <span className="chip accent">{s.extra}</span>}
      </div>
      <div className="bar"><i style={{ width: `${denom ? Math.round((s.records / denom) * 100) : 0}%` }} /></div>
      <div className="credit" style={{ whiteSpace: "normal" }}>Licence: {s.licence}</div>
      {s.status === "connected" && <div className="small" style={{ color: "var(--accent)", fontWeight: 600 }}>Open dashboard →</div>}
    </div>
  );
  return s.status === "connected"
    ? <Link to={`/sources/${s.id}`} className="card item-card">{body}</Link>
    : <div className="card item-card" style={{ cursor: "default", opacity: s.status === "unusable" ? 0.6 : 1 }}>{body}</div>;
}
