import { useQuery } from "@tanstack/react-query";
import { Link } from "react-router-dom";
import { api } from "../lib/api";
import { fmtDate, pct } from "../lib/format";
import { CONFIG_DOCS } from "../lib/config";
import { Layout } from "../components/Layout";
import { Icon, Skeleton } from "../components/ui";

function Kpi({ icon, value, label, sub, to, bar }: { icon: string; value: string | number; label: string; sub?: string; to?: string; bar?: number }) {
  const body = (
    <div className="card kpi">
      <Icon name={icon} fill />
      <div className="v">{value}</div>
      <div className="l">{label}</div>
      {sub && <div className="s">{sub}</div>}
      {bar !== undefined && <div className="bar"><i style={{ width: `${bar}%` }} /></div>}
    </div>
  );
  return to ? <Link to={to}>{body}</Link> : body;
}

export default function Dashboard() {
  const stats = useQuery({ queryKey: ["stats"], queryFn: api.stats });
  const products = useQuery({ queryKey: ["collection", "products"], queryFn: () => api.list("products") });
  const dishes = useQuery({ queryKey: ["collection", "dishes"], queryFn: () => api.list("dishes") });
  const s = stats.data;
  const p = products.data ?? [];
  const d = dishes.data ?? [];
  const pPhoto = p.filter((x) => x.imageUrl || get(x, "openData.bottlePhoto.imageUrl") || get(x, "openData.openFoodFacts.imageUrl")).length;
  const dPhoto = d.filter((x) => get(x, "openData.photo.imageUrl")).length;
  const estimated = p.filter((x) => get(x, "estimate.label")).length;
  const bestSellers = p.filter((x) => get(x, "bestSeller.note")).length;
  const groups = countBy(p, (x) => groupOf(String(x.category ?? "")));
  const cuisines = countBy(d, (x) => String(x.category ?? ""));

  return (
    <Layout title="Dashboard" crumbs="Overview">
      {!s ? <Skeleton /> : (
        <>
          <div className="grid kpis">
            <Kpi icon="wine_bar" value={s.drinks} label="Drinks" sub={`${s.verified} verified by a person`} to="/c/products" bar={pct(s.verified, s.drinks)} />
            <Kpi icon="photo_camera" value={`${pct(pPhoto, p.length)}%`} label="Drinks with a photo" sub={`${pPhoto} of ${p.length}`} to="/c/products" bar={pct(pPhoto, p.length)} />
            <Kpi icon="restaurant" value={s.dishes} label="Dishes" sub={`${dPhoto} with a photo`} to="/c/dishes" bar={pct(dPhoto, d.length)} />
            <Kpi icon="auto_awesome" value={estimated} label="Taste scores estimated" sub="labelled in the app" to="/c/products" />
            <Kpi icon="trending_up" value={bestSellers} label="Best-seller notes" to="/c/products" />
            <Kpi icon="group" value={s.users} label="Users" to="/users" />
            <Kpi icon="menu_book" value={s.journalEntries} label="BroCards (journal)" to="/users" />
            <Kpi icon="favorite" value={s.wishlistAdds} label="Wishlist adds" to="/users" />
            <Kpi icon="groups" value={s.communitySignals} label="Community signals" to="/c/community_signals" />
            <Kpi icon="thumb_up" value={s.pairingFeedback} label="Pairing feedback" to="/c/pairing_feedback" />
          </div>

          <div className="grid two">
            <div className="card">
              <div className="card-head"><h3>Drinks by group</h3><Link className="btn sm ghost" to="/c/products">Open</Link></div>
              <div className="card-pad stack">
                {Object.entries(groups).sort((a, b) => b[1] - a[1]).map(([g, n]) => (
                  <div key={g} className="score-row"><span>{g || "—"}</span><div className="bar accent"><i style={{ width: `${pct(n, p.length)}%` }} /></div><b>{n}</b></div>
                ))}
              </div>
            </div>
            <div className="card">
              <div className="card-head"><h3>Dishes by cuisine</h3><Link className="btn sm ghost" to="/c/dishes">Open</Link></div>
              <div className="card-pad stack">
                {Object.entries(cuisines).sort((a, b) => b[1] - a[1]).map(([g, n]) => (
                  <div key={g} className="score-row"><span style={{ overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{g}</span><div className="bar"><i style={{ width: `${pct(n, d.length)}%` }} /></div><b>{n}</b></div>
                ))}
              </div>
            </div>
          </div>

          <div className="card">
            <div className="card-head"><h3>Rules and lists</h3><Link className="btn sm ghost" to="/rules">Open</Link></div>
            <div className="table-wrap">
              <table className="tbl">
                <thead><tr><th>Document</th><th>Version</th><th>Last change</th><th>By</th></tr></thead>
                <tbody>
                  {CONFIG_DOCS.map((c) => {
                    const v = s.config.find((x) => x.id === c.id);
                    return (
                      <tr key={c.id} className="click" onClick={() => (window.location.href = `/rules/${c.id}`)}>
                        <td><Icon name={c.icon} className="sm" /> {c.title}</td>
                        <td><span className="pill-num">v{v?.version ?? "–"}</span></td>
                        <td>{fmtDate(v?.updatedAt)}</td>
                        <td>{v?.source === "admin" ? "Console" : v?.source === "code-export" ? "Initial export" : v?.source ?? ""}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </Layout>
  );
}

function get(o: unknown, path: string): unknown {
  return path.split(".").reduce<unknown>((x, k) => (x && typeof x === "object" ? (x as Record<string, unknown>)[k] : undefined), o);
}
function countBy<T>(list: T[], key: (t: T) => string): Record<string, number> {
  const out: Record<string, number> = {};
  for (const x of list) out[key(x)] = (out[key(x)] ?? 0) + 1;
  return out;
}
function groupOf(cat: string): string {
  if (/wine/i.test(cat)) return "Wine";
  if (/whisky/i.test(cat)) return "Whisky";
  if (/beer/i.test(cat)) return "Beer";
  return cat ? "Spirits" : "";
}
