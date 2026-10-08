import { useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { api } from "../lib/api";
import { Field, Icon, Select, Skeleton } from "../components/ui";

type Cond = { axis: string; op: string; value: number };
type Rule = { when: Cond[]; points: number };
type Rules = Record<string, unknown>;

function holds(c: Cond, read: (a: string) => number) {
  const v = read(c.axis);
  switch (c.op) {
    case ">=": return v >= c.value;
    case "<=": return v <= c.value;
    case ">": return v > c.value;
    case "<": return v < c.value;
    case "==": return v === c.value;
    default: return false;
  }
}

/** Same food-fit maths as the app's PairingEngine, for a preview before saving. */
export function foodFit(rules: Rules, dish: Record<string, unknown>, drink: Record<string, unknown>) {
  const read = (a: string) => Number(drink[a] ?? 0);
  const base = Number(rules.foodFitBase ?? 50);
  const floor = Number(rules.scoreFloor ?? 40), ceil = Number(rules.scoreCeiling ?? 99);
  const fit = (rules.foodFitRules ?? {}) as Record<string, Rule[]>;
  const lines: { property: string; points: number; rule?: Rule }[] = [];
  let points = base;
  for (const prop of (dish.foodProperties as string[]) ?? []) {
    const rule = (fit[prop] ?? []).find((r) => (r.when ?? []).every((c) => holds(c, read)));
    lines.push({ property: prop, points: rule?.points ?? 0, rule });
    points += rule?.points ?? 0;
  }
  const curated = ((dish.pairings as { productId: string; score: number; strategy: string; broTip: string }[]) ?? []).find((p) => p.productId === drink.id);
  if (curated) points = Math.max(points, Number(curated.score)) + Number(rules.curatedBonus ?? 0);
  const total = Math.min(ceil, Math.max(floor, points));
  const ind = (rules.strategyIndicators ?? {}) as Record<string, { property: string; when: Cond[] }[]>;
  const count = (list: { property: string; when: Cond[] }[] = []) => list.filter((i) => ((dish.foodProperties as string[]) ?? []).includes(i.property) && (i.when ?? []).every((c) => holds(c, read))).length;
  const strategy = curated?.strategy ?? (count(ind.contrast) > count(ind.complement) ? "contrast" : "complement");
  let text = String(rules.explanationDefault ?? "");
  const tpl = ((rules.explanations ?? []) as { strategy: string; property: string; text: string; why?: { when: Cond[]; text: string }[] }[])
    .find((t) => t.strategy === strategy && ((dish.foodProperties as string[]) ?? []).includes(t.property));
  if (curated?.broTip) text = curated.broTip;
  else if (tpl) {
    const why = (tpl.why ?? []).find((w) => (w.when ?? []).every((c) => holds(c, read)))?.text ?? "";
    text = tpl.text.replace("{why}", why);
  }
  text = text.replaceAll("{dish}", String(dish.name)).replaceAll("{drink}", String(drink.name)).replaceAll("{strategy}", strategy);
  return { base, lines, curated, total, strategy, text };
}

export function TryPairing({ rules }: { rules: Rules }) {
  const dishes = useQuery({ queryKey: ["collection", "dishes"], queryFn: () => api.list("dishes") });
  const drinks = useQuery({ queryKey: ["collection", "products"], queryFn: () => api.list("products") });
  const [dishId, setDishId] = useState("");
  const [drinkId, setDrinkId] = useState("");
  const dish = dishes.data?.find((d) => d.id === dishId);
  const result = useMemo(() => {
    if (!dish || !drinks.data) return null;
    const scored = drinks.data.map((p) => ({ drink: p, r: foodFit(rules, dish, p) })).sort((a, b) => b.r.total - a.r.total);
    return { scored, pick: scored.find((s) => s.drink.id === drinkId) };
  }, [dish, drinks.data, drinkId, rules]);

  if (dishes.isLoading || drinks.isLoading) return <Skeleton />;
  return (
    <div className="grid two">
      <div className="card card-pad stack">
        <h3>Pick a dish and a drink</h3>
        <div className="small muted">Uses the rules as edited on this page (unsaved changes included), so you can see the effect before saving.</div>
        <Field label="Dish"><Select value={dishId} allowEmpty options={(dishes.data ?? []).map((d) => ({ value: d.id, label: String(d.name) })).sort((a, b) => a.label.localeCompare(b.label))} onChange={setDishId} /></Field>
        <Field label="Drink"><Select value={drinkId} allowEmpty options={(drinks.data ?? []).map((d) => ({ value: d.id, label: `${d.name} (${d.category})` })).sort((a, b) => a.label.localeCompare(b.label))} onChange={setDrinkId} /></Field>
        {result?.pick && (
          <div className="card card-pad stack" style={{ background: "var(--surface-1)" }}>
            <div className="row between"><b>Food fit</b><span className="pill-num" style={{ fontSize: 18 }}>{Math.round(result.pick.r.total)}%</span></div>
            <div className="score-row"><span>Base</span><span /><b>{result.pick.r.base}</b></div>
            {result.pick.r.lines.map((l) => (
              <div key={l.property} className="score-row"><span>{l.property}</span><span className="small muted">{l.rule ? l.rule.when.map((c) => `${c.axis} ${c.op} ${c.value}`).join(" and ") : "no rule matched"}</span><b style={{ color: l.points < 0 ? "var(--error)" : l.points > 0 ? "var(--success)" : undefined }}>{l.points > 0 ? "+" : ""}{l.points}</b></div>
            ))}
            {result.pick.r.curated && <div className="score-row"><span>Hand-written</span><span className="small muted">floor {result.pick.r.curated.score} + bonus</span><b>+{Number(rules.curatedBonus ?? 0)}</b></div>}
            <div className="row"><span className="chip accent">{result.pick.r.strategy}</span></div>
            <div className="small" style={{ fontStyle: "italic" }}>“{result.pick.r.text}”</div>
          </div>
        )}
      </div>
      <div className="card">
        <div className="card-head"><h3>Best drinks for {dish ? String(dish.name) : "…"}</h3><span className="small muted">food fit only</span></div>
        {!result ? <div className="card-pad muted small">Pick a dish to see the ranking.</div> : (
          <div className="table-wrap" style={{ maxHeight: 520 }}>
            <table className="tbl">
              <thead><tr><th>#</th><th>Drink</th><th>Category</th><th>Fit</th><th>Strategy</th></tr></thead>
              <tbody>
                {result.scored.slice(0, 25).map((s, i) => (
                  <tr key={s.drink.id} className="click" onClick={() => setDrinkId(s.drink.id)} style={s.drink.id === drinkId ? { background: "color-mix(in srgb, var(--paprika) 8%, transparent)" } : undefined}>
                    <td className="num">{i + 1}</td><td>{String(s.drink.name)}{s.r.curated && <Icon name="edit_note" className="sm" />}</td><td>{String(s.drink.category)}</td><td className="num"><b>{Math.round(s.r.total)}</b></td><td>{s.r.strategy}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
