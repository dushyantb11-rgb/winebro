import React from "react";
import { ConfigMap, Option } from "../lib/config";
import { ICON_NAMES } from "../lib/icons";
import { slug } from "../lib/format";
import { Field, Icon, IconPicker, NumberInput, Select, Tags, TextInput, Toggle } from "../components/ui";

type Obj = Record<string, unknown>;
type Cond = { axis: string; op: string; value: number };
type Props = { doc: string; value: Obj; onChange: (v: Obj) => void; options: Record<string, Option[]>; all?: ConfigMap };

const AXES = ["fruit", "acidity", "body", "tannin", "freshness", "complexity"];
const OPS = [">=", "<=", ">", "<", "=="];

export function RuleForm(p: Props) {
  switch (p.doc) {
    case "pairingRules": return <PairingRulesForm {...p} />;
    case "archetypes": return <ArchetypesForm {...p} />;
    case "quiz": return <QuizForm {...p} />;
    case "scanner": return <ScannerForm {...p} />;
    case "gamification": return <GamificationForm {...p} />;
    case "badges": return <BadgesForm {...p} />;
    case "categories": return <CategoriesForm {...p} />;
    case "occasions": return <OccasionsForm {...p} />;
    case "journalScales": return <JournalScalesForm {...p} />;
    case "aromaWheel": return <AromaWheelForm {...p} />;
    case "home": return <HomeForm {...p} />;
    case "notifications": return <NotificationsForm {...p} />;
    default: return <div className="muted">Use the JSON tab for this document.</div>;
  }
}

// ── shared bits ──────────────────────────────────────────────────
function Section({ title, hint, children, actions }: { title: string; hint?: string; children: React.ReactNode; actions?: React.ReactNode }) {
  return (
    <div className="card">
      <div className="card-head"><div><h3>{title}</h3>{hint && <div className="small muted">{hint}</div>}</div>{actions}</div>
      <div className="card-pad stack">{children}</div>
    </div>
  );
}

function num(v: unknown, d = 0): number { return typeof v === "number" ? v : d; }
function str(v: unknown, d = ""): string { return typeof v === "string" ? v : d; }
function arr<T = Obj>(v: unknown): T[] { return Array.isArray(v) ? (v as T[]) : []; }
function obj(v: unknown): Obj { return v && typeof v === "object" && !Array.isArray(v) ? (v as Obj) : {}; }

function useSet(value: Obj, onChange: (v: Obj) => void) {
  return (key: string, v: unknown) => onChange({ ...value, [key]: v });
}

function NumField({ label, value, onChange, hint, step = 1, min, max }: { label: string; value: unknown; onChange: (n: number) => void; hint?: string; step?: number; min?: number; max?: number }) {
  return <Field label={label} hint={hint}><NumberInput value={num(value)} step={step} min={min} max={max} onChange={(n) => onChange(n ?? 0)} /></Field>;
}

function Conditions({ value, onChange, axes }: { value: Cond[]; onChange: (c: Cond[]) => void; axes: Option[] }) {
  const upd = (i: number, patch: Partial<Cond>) => onChange(value.map((c, j) => (j === i ? { ...c, ...patch } : c)));
  return (
    <div className="stack" style={{ gap: 6 }}>
      {value.map((c, i) => (
        <div key={i} className="cond">
          <select className="select" value={c.axis} onChange={(e) => upd(i, { axis: e.target.value })}>{axes.map((a) => <option key={a.value} value={a.value}>{a.label}</option>)}</select>
          <select className="select" value={c.op} onChange={(e) => upd(i, { op: e.target.value })}>{OPS.map((o) => <option key={o}>{o}</option>)}</select>
          <input className="input" type="number" step={0.5} value={c.value} onChange={(e) => upd(i, { value: Number(e.target.value) })} />
          <button type="button" className="btn ghost icon" onClick={() => onChange(value.filter((_, j) => j !== i))} aria-label="Remove condition"><Icon name="close" className="sm" /></button>
        </div>
      ))}
      <button type="button" className="btn ghost sm" style={{ alignSelf: "flex-start" }} onClick={() => onChange([...value, { axis: axes[0]?.value ?? "fruit", op: ">=", value: 6 }])}><Icon name="add" className="sm" />Condition</button>
    </div>
  );
}

function ListEditor<T extends Obj>({ items, onChange, render, blank, addLabel, title }: {
  items: T[]; onChange: (v: T[]) => void; render: (item: T, update: (patch: Partial<T>) => void, index: number) => React.ReactNode; blank: () => T; addLabel: string; title?: (t: T) => string;
}) {
  const move = (i: number, d: number) => {
    const j = i + d; if (j < 0 || j >= items.length) return;
    const n = [...items]; [n[i], n[j]] = [n[j], n[i]]; onChange(n);
  };
  return (
    <div className="stack">
      {items.map((it, i) => (
        <div key={i} className="rule">
          <div className="stack" style={{ gap: 8 }}>{title && <b>{title(it)}</b>}{render(it, (patch) => onChange(items.map((x, j) => (j === i ? { ...x, ...patch } : x))), i)}</div>
          <div className="stack" style={{ gap: 2 }}>
            <button type="button" className="btn ghost icon" onClick={() => move(i, -1)} aria-label="Up"><Icon name="arrow_upward" className="sm" /></button>
            <button type="button" className="btn ghost icon" onClick={() => move(i, 1)} aria-label="Down"><Icon name="arrow_downward" className="sm" /></button>
            <button type="button" className="btn ghost icon" onClick={() => onChange(items.filter((_, j) => j !== i))} aria-label="Remove"><Icon name="delete" className="sm" /></button>
          </div>
        </div>
      ))}
      <button type="button" className="btn sm" style={{ alignSelf: "flex-start" }} onClick={() => onChange([...items, blank()])}><Icon name="add" className="sm" />{addLabel}</button>
    </div>
  );
}

function CodeField({ value, onChange, locked }: { value: string; onChange: (v: string) => void; locked?: boolean }) {
  return <Field label="Code" hint={locked ? "Used by existing data; keep as is" : "letters and digits, no spaces"}><TextInput value={value} disabled={locked} onChange={(e) => onChange(e.target.value.replace(/[^A-Za-z0-9_]/g, ""))} /></Field>;
}

// ── Pairing rules ────────────────────────────────────────────────
function PairingRulesForm({ value, onChange, options }: Props) {
  const set = useSet(value, onChange);
  const axes = options.axes?.length ? options.axes : AXES.map((a) => ({ value: a, label: a }));
  const props = options.foodProperties ?? [];
  const weights = obj(value.axisWeights);
  const penalty = obj(value.frequencyPenalty);
  const fit = obj(value.foodFitRules) as Record<string, { when: Cond[]; points: number }[]>;
  const ind = obj(value.strategyIndicators) as Record<string, { property: string; when: Cond[] }[]>;
  const expl = arr<{ strategy: string; property: string; text: string; why?: { when: Cond[]; text: string }[] }>(value.explanations);
  return (
    <div className="stack" style={{ gap: 16 }}>
      <Section title="Scale and blend" hint="Scores run from floor to ceiling. For 'what to drink with this dish', the dish fit counts for the food weight and the person's palate for the rest.">
        <div className="grid form">
          <NumField label="Score floor" value={value.scoreFloor} onChange={(n) => set("scoreFloor", n)} />
          <NumField label="Score ceiling" value={value.scoreCeiling} onChange={(n) => set("scoreCeiling", n)} />
          <NumField label="Food weight (0–1)" value={value.foodWeight} step={0.05} min={0} max={1} onChange={(n) => set("foodWeight", n)} />
          <NumField label="Food-fit base points" value={value.foodFitBase} onChange={(n) => set("foodFitBase", n)} />
          <NumField label="Hand-written pairing bonus" value={value.curatedBonus} onChange={(n) => set("curatedBonus", n)} />
          <NumField label="Community feedback cap (points)" value={value.feedbackBiasCapPoints} onChange={(n) => set("feedbackBiasCapPoints", n)} />
        </div>
      </Section>
      <Section title="Palate match: axis weights" hint="How much each taste axis counts when comparing a person's palate with a drink.">
        <div className="grid form">
          {axes.map((a) => <NumField key={a.value} label={a.label} value={weights[a.value]} step={0.1} min={0} onChange={(n) => set("axisWeights", { ...weights, [a.value]: n })} />)}
        </div>
      </Section>
      <Section title="Repeat penalty" hint="Points taken off when the same drink was already recommended (unless the person rated it 5 stars).">
        <div className="grid form">
          <NumField label="Second time" value={penalty.second} onChange={(n) => set("frequencyPenalty", { ...penalty, second: n })} />
          <NumField label="Third time" value={penalty.third} onChange={(n) => set("frequencyPenalty", { ...penalty, third: n })} />
          <NumField label="Fourth time and later" value={penalty.cap} onChange={(n) => set("frequencyPenalty", { ...penalty, cap: n })} />
        </div>
      </Section>
      <Section title="Food-fit rules" hint="For each food property, the first rule whose conditions the drink meets gives its points (plus or minus). Rules are tried top to bottom.">
        {props.map((p) => (
          <div key={p.value} className="stack" style={{ gap: 8 }}>
            <div className="section-title"><Icon name="rule" className="sm" /><b>{p.label}</b><span className="small muted">{p.value}</span></div>
            <ListEditor items={fit[p.value] ?? []} onChange={(rules) => set("foodFitRules", { ...fit, [p.value]: rules })} addLabel="Rule" blank={() => ({ when: [{ axis: "fruit", op: ">=", value: 6 }], points: 10 })}
              render={(r, upd) => (
                <div className="grid form" style={{ gridTemplateColumns: "1fr 120px" }}>
                  <Field label="When"><Conditions value={r.when ?? []} onChange={(when) => upd({ when })} axes={axes} /></Field>
                  <NumField label="Points" value={r.points} onChange={(points) => upd({ points })} />
                </div>
              )} />
          </div>
        ))}
      </Section>
      <Section title="Contrast or complement?" hint="The pairing is called a contrast when more contrast indicators hold than complement indicators.">
        {(["contrast", "complement"] as const).map((k) => (
          <div key={k} className="stack" style={{ gap: 8 }}>
            <b style={{ textTransform: "capitalize" }}>{k} indicators</b>
            <ListEditor items={ind[k] ?? []} onChange={(list) => set("strategyIndicators", { ...ind, [k]: list })} addLabel="Indicator" blank={() => ({ property: props[0]?.value ?? "", when: [] as Cond[] })}
              render={(it, upd) => (
                <div className="grid form" style={{ gridTemplateColumns: "200px 1fr" }}>
                  <Field label="Food property"><Select value={it.property} options={props} onChange={(property) => upd({ property })} /></Field>
                  <Field label="Drink conditions"><Conditions value={it.when ?? []} onChange={(when) => upd({ when })} axes={axes} /></Field>
                </div>
              )} />
          </div>
        ))}
      </Section>
      <Section title="Bro-tip wording" hint="First template matching the strategy and a food property of the dish is used. Placeholders: {dish} {drink} {strategy} {why}.">
        <ListEditor items={expl} onChange={(e) => set("explanations", e)} addLabel="Template" blank={() => ({ strategy: "contrast", property: props[0]?.value ?? "", text: "{drink} and {dish}…", why: [] as { when: Cond[]; text: string }[] })}
          render={(t, upd) => (
            <div className="stack" style={{ gap: 8 }}>
              <div className="grid form" style={{ gridTemplateColumns: "160px 200px" }}>
                <Field label="Strategy"><Select value={t.strategy} options={[{ value: "contrast", label: "Contrast" }, { value: "complement", label: "Complement" }]} onChange={(strategy) => upd({ strategy })} /></Field>
                <Field label="Food property"><Select value={t.property} options={props} onChange={(property) => upd({ property })} /></Field>
              </div>
              <Field label="Text"><textarea className="textarea" style={{ minHeight: 64 }} value={t.text} onChange={(e) => upd({ text: e.target.value })} /></Field>
              {t.text.includes("{why}") && (
                <Field label="{why} variants (first match wins; a variant with no conditions is the fallback)">
                  <ListEditor items={t.why ?? []} onChange={(why) => upd({ why })} addLabel="Variant" blank={() => ({ when: [] as Cond[], text: "" })}
                    render={(w, u2) => (
                      <div className="grid form" style={{ gridTemplateColumns: "1fr 1fr" }}>
                        <Field label="When"><Conditions value={w.when ?? []} onChange={(when) => u2({ when })} axes={axes} /></Field>
                        <Field label="Text"><TextInput value={w.text} onChange={(e) => u2({ text: e.target.value })} /></Field>
                      </div>
                    )} />
                </Field>
              )}
            </div>
          )} />
        <Field label="Default text (no template matched)"><textarea className="textarea" style={{ minHeight: 56 }} value={str(value.explanationDefault)} onChange={(e) => set("explanationDefault", e.target.value)} /></Field>
      </Section>
    </div>
  );
}

// ── Archetypes ───────────────────────────────────────────────────
function ArchetypesForm({ value, onChange, options }: Props) {
  const set = useSet(value, onChange);
  const items = arr<{ code: string; displayName: string; description: string; icon: string; bonusPercent: number }>(value.items);
  const rules = arr<{ archetype: string; when?: Cond[]; allAxes?: { min: number; max: number }; rank?: { sum?: string[]; sumInverted?: string[]; lowVariance?: number } }>(value.rules);
  const axes = options.axes?.length ? options.axes : AXES.map((a) => ({ value: a, label: a }));
  const codes = items.map((i) => ({ value: i.code, label: i.displayName || i.code }));
  return (
    <div className="stack" style={{ gap: 16 }}>
      <Section title="Archetypes" hint="The palate types a person can be. Bonus % is added to a drink's match when the drink is tagged with the person's archetype.">
        <ListEditor items={items} onChange={(v) => set("items", v)} addLabel="Archetype" blank={() => ({ code: "", displayName: "", description: "", icon: "wine_bar", bonusPercent: 10 })} title={(i) => i.displayName || i.code || "New"}
          render={(it, upd, i) => (
            <div className="grid form">
              <CodeField value={it.code} locked={i < 5 && !!it.code} onChange={(code) => upd({ code })} />
              <Field label="Name"><TextInput value={it.displayName} onChange={(e) => upd({ displayName: e.target.value, ...(it.code ? {} : { code: camel(e.target.value) }) })} /></Field>
              <Field label="Icon"><IconPicker value={it.icon} names={ICON_NAMES} onChange={(icon) => upd({ icon })} /></Field>
              <NumField label="Bonus %" value={it.bonusPercent} onChange={(bonusPercent) => upd({ bonusPercent })} />
              <div className="span2"><Field label="Description (shown after the quiz)"><textarea className="textarea" style={{ minHeight: 56 }} value={it.description} onChange={(e) => upd({ description: e.target.value })} /></Field></div>
            </div>
          )} />
      </Section>
      <Section title="Who is which archetype" hint="A profile qualifies for every rule whose conditions hold; the highest rank wins. Rank = sum of the listed axes (+ 10 minus each inverted axis). 'Low variance' ranks balanced profiles.">
        <ListEditor items={rules} onChange={(v) => set("rules", v)} addLabel="Rule" blank={() => ({ archetype: codes[0]?.value ?? "", when: [] as Cond[], rank: { sum: [] as string[] } })} title={(r) => codes.find((c) => c.value === r.archetype)?.label ?? r.archetype}
          render={(r, upd) => (
            <div className="grid form">
              <Field label="Archetype"><Select value={r.archetype} options={codes} onChange={(archetype) => upd({ archetype })} /></Field>
              <Field label="All axes between (optional)">
                <div className="row" style={{ flexWrap: "nowrap" }}>
                  <NumberInput value={r.allAxes?.min} placeholder="min" onChange={(n) => upd({ allAxes: n === undefined && r.allAxes?.max === undefined ? undefined : { min: n ?? 0, max: r.allAxes?.max ?? 10 } })} />
                  <NumberInput value={r.allAxes?.max} placeholder="max" onChange={(n) => upd({ allAxes: n === undefined && r.allAxes?.min === undefined ? undefined : { min: r.allAxes?.min ?? 0, max: n ?? 10 } })} />
                </div>
              </Field>
              <div className="span2"><Field label="Conditions"><Conditions value={r.when ?? []} onChange={(when) => upd({ when })} axes={axes} /></Field></div>
              <Field label="Rank: add these axes"><Tags value={r.rank?.sum ?? []} options={axes} onChange={(sum) => upd({ rank: { ...r.rank, sum } })} /></Field>
              <Field label="Rank: add (10 − axis) for these"><Tags value={r.rank?.sumInverted ?? []} options={axes} onChange={(sumInverted) => upd({ rank: { ...r.rank, sumInverted } })} /></Field>
              <Field label="Low-variance rank (optional)" hint="rank += this − variance"><NumberInput value={r.rank?.lowVariance} onChange={(lowVariance) => upd({ rank: { ...r.rank, lowVariance } })} /></Field>
            </div>
          )} />
        <Field label="Fallback archetype (no rule matched)"><Select value={str(value.fallback)} options={codes} onChange={(f) => set("fallback", f)} /></Field>
      </Section>
    </div>
  );
}

function camel(s: string) {
  const parts = slug(s).split("-").filter(Boolean);
  return parts.map((p, i) => (i ? p[0].toUpperCase() + p.slice(1) : p)).join("");
}

// ── Quiz ─────────────────────────────────────────────────────────
function QuizForm({ value, onChange, options }: Props) {
  const set = useSet(value, onChange);
  const axes = options.axes?.length ? options.axes : AXES.map((a) => ({ value: a, label: a }));
  const steps = arr<{ id: string; multi?: boolean; optional?: boolean; answers: { id: string; label: string; icon: string; axes: Record<string, number> }[] }>(value.steps);
  return (
    <div className="stack" style={{ gap: 16 }}>
      <Section title="Scale and blend">
        <div className="grid form">
          <NumField label="Axis minimum" value={value.axisMin} onChange={(n) => set("axisMin", n)} />
          <NumField label="Axis maximum" value={value.axisMax} onChange={(n) => set("axisMax", n)} />
          <NumField label="Quiz weight" value={value.quizBlendWeight} step={0.05} onChange={(n) => set("quizBlendWeight", n)} hint="Share of the quiz answers in the final profile" />
          <NumField label="Slider weight" value={value.sliderBlendWeight} step={0.05} onChange={(n) => set("sliderBlendWeight", n)} hint="Share of the manual sliders" />
          <NumField label="Tried-bottles prior" value={value.triedPriorWeight} step={0.05} onChange={(n) => set("triedPriorWeight", n)} hint="Weight of bottles the person says they have tried" />
        </div>
      </Section>
      {steps.map((s, si) => (
        <Section key={s.id} title={`Step: ${s.id}`} hint={`${s.multi ? "Several answers" : "One answer"}${s.optional ? ", optional" : ""}. Each answer adds points to the six taste axes.`}>
          <ListEditor items={s.answers ?? []} onChange={(answers) => set("steps", steps.map((x, j) => (j === si ? { ...x, answers } : x)))} addLabel="Answer" blank={() => ({ id: "", label: "", icon: "restaurant", axes: Object.fromEntries(AXES.map((a) => [a, 2])) })} title={(a) => a.label || a.id || "New"}
            render={(a, upd) => (
              <div className="grid form">
                <Field label="Label"><TextInput value={a.label} onChange={(e) => upd({ label: e.target.value, ...(a.id ? {} : { id: slug(e.target.value) }) })} /></Field>
                <Field label="ID" hint="stable id"><TextInput value={a.id} onChange={(e) => upd({ id: slug(e.target.value) })} /></Field>
                <Field label="Icon"><IconPicker value={a.icon} names={ICON_NAMES} onChange={(icon) => upd({ icon })} /></Field>
                <div className="span2 grid form" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(110px, 1fr))" }}>
                  {axes.map((x) => <NumField key={x.value} label={x.label} value={a.axes?.[x.value]} step={0.5} onChange={(n) => upd({ axes: { ...a.axes, [x.value]: n } })} />)}
                </div>
              </div>
            )} />
        </Section>
      ))}
    </div>
  );
}

// ── Scanner ──────────────────────────────────────────────────────
function ScannerForm({ value, onChange }: Props) {
  const set = useSet(value, onChange);
  return (
    <Section title="Label matching" hint="A drink matches when at least this share of its name words is found on the label; the brand word must always be found.">
      <div className="grid form">
        <NumField label="Minimum score (0–1)" value={value.minScore} step={0.05} min={0} max={1} onChange={(n) => set("minScore", n)} />
        <NumField label="Fuzzy similarity (0–1)" value={value.fuzzyThreshold} step={0.05} min={0} max={1} onChange={(n) => set("fuzzyThreshold", n)} hint="How close a misread word must be to count" />
        <NumField label="Min word length for fuzzy" value={value.minFuzzyWordLength} min={1} onChange={(n) => set("minFuzzyWordLength", n)} />
      </div>
      <Field label="Words ignored in names" hint="e.g. vineyard, estate, distillery"><Tags value={arr<string>(value.genericWords)} onChange={(w) => set("genericWords", w.map((x) => x.toLowerCase()))} /></Field>
    </Section>
  );
}

// ── Gamification ─────────────────────────────────────────────────
function GamificationForm({ value, onChange }: Props) {
  const set = useSet(value, onChange);
  const actions = obj(value.actions) as Record<string, number>;
  const levels = arr<{ level: number; name: string; minXp: number; icon: string }>(value.levels);
  return (
    <div className="stack" style={{ gap: 16 }}>
      <Section title="XP per action">
        <div className="grid form">
          {[["scan", "Scan a label"], ["journalEntry", "Save a BroCard"], ["pairing", "Log a pairing"]].map(([k, l]) => (
            <NumField key={k} label={l} value={actions[k]} onChange={(n) => set("actions", { ...actions, [k]: n })} />
          ))}
        </div>
      </Section>
      <Section title="Levels" hint="Level numbers start at 0. A person is at the highest level whose minimum XP they have reached.">
        <ListEditor items={levels} onChange={(v) => set("levels", v.map((l, i) => ({ ...l, level: i })))} addLabel="Level" blank={() => ({ level: levels.length, name: "", minXp: (levels.at(-1)?.minXp ?? 0) * 2 || 500, icon: "star" })} title={(l) => `Level ${l.level}`}
          render={(l, upd) => (
            <div className="grid form">
              <Field label="Name"><TextInput value={l.name} onChange={(e) => upd({ name: e.target.value })} /></Field>
              <NumField label="Minimum XP" value={l.minXp} onChange={(minXp) => upd({ minXp })} />
              <Field label="Icon"><IconPicker value={l.icon} names={ICON_NAMES} onChange={(icon) => upd({ icon })} /></Field>
            </div>
          )} />
      </Section>
    </div>
  );
}

// ── Badges ───────────────────────────────────────────────────────
const CONDITION_TYPES = [
  { value: "scanCount", label: "Scanned N bottles" },
  { value: "journalCount", label: "Saved N BroCards" },
  { value: "pairingCount", label: "Logged N pairings" },
  { value: "streakDays", label: "Streak of N days" },
  { value: "categoryExplored", label: "Explored a category 5 times (value = category)" },
  { value: "challengeCount", label: "Completed N challenges" },
  { value: "special", label: "Special rule (key)" },
];
function BadgesForm({ value, onChange }: Props) {
  const set = useSet(value, onChange);
  const items = arr<{ id: string; name: string; description: string; icon: string; xpReward: number; condition: { type: string; value: unknown } }>(value.items);
  return (
    <Section title="Badges" hint="Earning a badge also gives its XP reward.">
      <ListEditor items={items} onChange={(v) => set("items", v)} addLabel="Badge" blank={() => ({ id: "", name: "", description: "", icon: "military_tech", xpReward: 50, condition: { type: "scanCount", value: 10 } })} title={(b) => b.name || b.id || "New badge"}
        render={(b, upd) => {
          const numeric = !["categoryExplored", "special"].includes(b.condition?.type);
          return (
            <div className="grid form">
              <Field label="Name"><TextInput value={b.name} onChange={(e) => upd({ name: e.target.value, ...(b.id ? {} : { id: slug(e.target.value) }) })} /></Field>
              <Field label="ID"><TextInput value={b.id} onChange={(e) => upd({ id: slug(e.target.value) })} /></Field>
              <Field label="Icon"><IconPicker value={b.icon} names={ICON_NAMES} onChange={(icon) => upd({ icon })} /></Field>
              <NumField label="XP reward" value={b.xpReward} onChange={(xpReward) => upd({ xpReward })} />
              <Field label="Condition"><Select value={b.condition?.type} options={CONDITION_TYPES} onChange={(type) => upd({ condition: { type, value: ["categoryExplored", "special"].includes(type) ? "" : 1 } })} /></Field>
              <Field label={numeric ? "N" : "Value"}>{numeric
                ? <NumberInput value={num(b.condition?.value)} onChange={(n) => upd({ condition: { ...b.condition, value: n ?? 0 } })} />
                : <TextInput value={str(b.condition?.value)} onChange={(e) => upd({ condition: { ...b.condition, value: e.target.value } })} />}</Field>
              <div className="span2"><Field label="Description"><TextInput value={b.description} onChange={(e) => upd({ description: e.target.value })} /></Field></div>
            </div>
          );
        }} />
    </Section>
  );
}

// ── Categories ───────────────────────────────────────────────────
function CategoriesForm({ value, onChange }: Props) {
  const set = useSet(value, onChange);
  const groups = arr<{ name: string; image: string }>(value.drinkGroups);
  const drinks = arr<{ code: string; displayName: string; group: string }>(value.drinks);
  const cuisines = arr<{ code: string; displayName: string; icon: string }>(value.cuisines);
  const props = arr<{ code: string; displayName: string }>(value.foodProperties);
  const strategies = arr<{ code: string; displayName: string; description: string }>(value.pairingStrategies);
  const axes = arr<{ code: string; displayName: string }>(value.palateAxes);
  const groupOpts = groups.map((g) => ({ value: g.name, label: g.name }));
  return (
    <div className="stack" style={{ gap: 16 }}>
      <Section title="Drink groups" hint="Top-level groups shown as tiles. The image is an app asset path or an uploaded image URL.">
        <ListEditor items={groups} onChange={(v) => set("drinkGroups", v)} addLabel="Group" blank={() => ({ name: "", image: "assets/images/drinks/cocktails.jpg" })}
          render={(g, upd) => (
            <div className="grid form">
              <Field label="Name"><TextInput value={g.name} onChange={(e) => upd({ name: e.target.value })} /></Field>
              <Field label="Image (asset path or URL)"><TextInput value={g.image} onChange={(e) => upd({ image: e.target.value })} /></Field>
            </div>
          )} />
      </Section>
      <Section title="Drink categories" hint="Add a category here and it is available in the app and in the drink editor straight away.">
        <ListEditor items={drinks} onChange={(v) => set("drinks", v)} addLabel="Category" blank={() => ({ code: "", displayName: "", group: groupOpts[0]?.value ?? "Spirits" })} title={(d) => d.displayName || d.code || "New"}
          render={(d, upd, i) => (
            <div className="grid form">
              <Field label="Name"><TextInput value={d.displayName} onChange={(e) => upd({ displayName: e.target.value, ...(d.code ? {} : { code: camel(e.target.value) }) })} /></Field>
              <CodeField value={d.code} locked={i < 13 && !!d.code} onChange={(code) => upd({ code })} />
              <Field label="Group"><Select value={d.group} options={groupOpts} onChange={(group) => upd({ group })} /></Field>
            </div>
          )} />
      </Section>
      <Section title="Cuisines">
        <ListEditor items={cuisines} onChange={(v) => set("cuisines", v)} addLabel="Cuisine" blank={() => ({ code: "", displayName: "", icon: "restaurant" })} title={(c) => c.displayName || c.code || "New"}
          render={(c, upd, i) => (
            <div className="grid form">
              <Field label="Name"><TextInput value={c.displayName} onChange={(e) => upd({ displayName: e.target.value, ...(c.code ? {} : { code: camel(e.target.value) }) })} /></Field>
              <CodeField value={c.code} locked={i < 8 && !!c.code} onChange={(code) => upd({ code })} />
              <Field label="Icon"><IconPicker value={c.icon} names={ICON_NAMES} onChange={(icon) => upd({ icon })} /></Field>
            </div>
          )} />
      </Section>
      <Section title="Food properties" hint="What a dish can be. Pairing rules react to these.">
        <ListEditor items={props} onChange={(v) => set("foodProperties", v)} addLabel="Property" blank={() => ({ code: "", displayName: "" })} title={(c) => c.displayName || c.code || "New"}
          render={(c, upd, i) => (
            <div className="grid form">
              <Field label="Name"><TextInput value={c.displayName} onChange={(e) => upd({ displayName: e.target.value, ...(c.code ? {} : { code: camel(e.target.value) }) })} /></Field>
              <CodeField value={c.code} locked={i < 11 && !!c.code} onChange={(code) => upd({ code })} />
            </div>
          )} />
      </Section>
      <Section title="Pairing strategies">
        {strategies.map((s, i) => (
          <div key={s.code} className="grid form">
            <Field label={`${s.code}: name`}><TextInput value={s.displayName} onChange={(e) => set("pairingStrategies", strategies.map((x, j) => (j === i ? { ...x, displayName: e.target.value } : x)))} /></Field>
            <Field label="Description"><TextInput value={s.description} onChange={(e) => set("pairingStrategies", strategies.map((x, j) => (j === i ? { ...x, description: e.target.value } : x)))} /></Field>
          </div>
        ))}
      </Section>
      <Section title="Taste axis names" hint="The six axes are fixed; their names are yours.">
        <div className="grid form">
          {axes.map((a, i) => <Field key={a.code} label={a.code}><TextInput value={a.displayName} onChange={(e) => set("palateAxes", axes.map((x, j) => (j === i ? { ...x, displayName: e.target.value } : x)))} /></Field>)}
        </div>
      </Section>
    </div>
  );
}

// ── Occasions ────────────────────────────────────────────────────
function OccasionsForm({ value, onChange, options }: Props) {
  const set = useSet(value, onChange);
  const items = arr<{ code: string; displayName: string; icon: string; axisModifiers: Record<string, number>; categoryBonus?: { category: string; bonusPercent: number } }>(value.items);
  const axes = options.axes?.length ? options.axes : AXES.map((a) => ({ value: a, label: a }));
  return (
    <Section title="Occasions" hint="Taste nudges are added to the person's palate for that occasion (e.g. body +1.5 for a BBQ). A category bonus adds points to drinks of that category.">
      <ListEditor items={items} onChange={(v) => set("items", v)} addLabel="Occasion" blank={() => ({ code: "", displayName: "", icon: "celebration", axisModifiers: {} as Record<string, number>, categoryBonus: undefined as { category: string; bonusPercent: number } | undefined })} title={(o) => o.displayName || o.code || "New"}
        render={(o, upd, i) => (
          <div className="grid form">
            <Field label="Name"><TextInput value={o.displayName} onChange={(e) => upd({ displayName: e.target.value, ...(o.code ? {} : { code: camel(e.target.value) }) })} /></Field>
            <CodeField value={o.code} locked={i < 6 && !!o.code} onChange={(code) => upd({ code })} />
            <Field label="Icon"><IconPicker value={o.icon} names={ICON_NAMES} onChange={(icon) => upd({ icon })} /></Field>
            <div className="span2 grid form" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(110px, 1fr))" }}>
              {axes.map((a) => <Field key={a.value} label={`${a.label} nudge`}><NumberInput value={o.axisModifiers?.[a.value]} step={0.5} onChange={(n) => { const m = { ...o.axisModifiers }; if (n === undefined || n === 0) delete m[a.value]; else m[a.value] = n; upd({ axisModifiers: m }); }} /></Field>)}
            </div>
            <Field label="Bonus for category (optional)"><Select value={o.categoryBonus?.category} allowEmpty options={options.drinks ?? []} onChange={(c) => upd({ categoryBonus: c ? { category: c, bonusPercent: o.categoryBonus?.bonusPercent ?? 10 } : undefined })} /></Field>
            {o.categoryBonus && <NumField label="Bonus points" value={o.categoryBonus.bonusPercent} onChange={(bonusPercent) => upd({ categoryBonus: { ...o.categoryBonus!, bonusPercent } })} />}
          </div>
        )} />
    </Section>
  );
}

// ── Journal scales ───────────────────────────────────────────────
function JournalScalesForm({ value, onChange }: Props) {
  const set = useSet(value, onChange);
  const keys = Object.keys(value).filter((k) => Array.isArray(value[k]));
  return (
    <Section title="Journal pick lists" hint="Reference lists for a BroCard. The app's pickers still use its built-in scales; this is for export and future use.">
      <div className="grid form">
        {keys.map((k) => <Field key={k} label={k}><Tags value={arr<string>(value[k])} onChange={(v) => set(k, v)} /></Field>)}
        <NumField label="Rating maximum (stars)" value={value.ratingMax} onChange={(n) => set("ratingMax", n)} />
      </div>
    </Section>
  );
}

// ── Aroma wheel ──────────────────────────────────────────────────
function AromaWheelForm({ value, onChange }: Props) {
  const set = useSet(value, onChange);
  const cats = arr<{ name: string; color: string; subcategories: { name: string; aromas: string[] }[] }>(value.categories);
  const cal = obj(value.calibration);
  return (
    <div className="stack" style={{ gap: 16 }}>
      <Section title="Aroma families">
        <ListEditor items={cats} onChange={(v) => set("categories", v)} addLabel="Family" blank={() => ({ name: "", color: "#93003C", subcategories: [] })} title={(c) => c.name || "New family"}
          render={(c, upd) => (
            <div className="stack">
              <div className="grid form">
                <Field label="Name"><TextInput value={c.name} onChange={(e) => upd({ name: e.target.value })} /></Field>
                <Field label="Colour"><div className="row" style={{ flexWrap: "nowrap" }}><input type="color" value={c.color.length === 7 ? c.color : "#93003C"} onChange={(e) => upd({ color: e.target.value.toUpperCase() })} style={{ width: 44, height: 38, border: 0, background: "none" }} /><TextInput value={c.color} onChange={(e) => upd({ color: e.target.value })} /></div></Field>
              </div>
              <ListEditor items={c.subcategories ?? []} onChange={(subcategories) => upd({ subcategories })} addLabel="Sub-family" blank={() => ({ name: "", aromas: [] })}
                render={(s, u2) => (
                  <div className="grid form" style={{ gridTemplateColumns: "200px 1fr" }}>
                    <Field label="Sub-family"><TextInput value={s.name} onChange={(e) => u2({ name: e.target.value })} /></Field>
                    <Field label="Aromas"><Tags value={s.aromas ?? []} onChange={(aromas) => u2({ aromas })} /></Field>
                  </div>
                )} />
            </div>
          )} />
      </Section>
      <Section title="Indian-context terms and calibration" hint="Terms treated as Indian-context in the aroma calibration; the session shows this many aromas with the given Indian share.">
        <Field label="Indian terms"><Tags value={arr<string>(value.desiTerms)} onChange={(v) => set("desiTerms", v)} /></Field>
        <div className="grid form">
          <NumField label="Aromas per session" value={cal.count} onChange={(n) => set("calibration", { ...cal, count: n })} />
          <NumField label="Indian share (0–1)" value={cal.indianShare} step={0.05} min={0} max={1} onChange={(n) => set("calibration", { ...cal, indianShare: n })} />
        </div>
      </Section>
    </div>
  );
}

// ── Home ─────────────────────────────────────────────────────────
const TOKENS = ["paprika", "paprikaLight", "paprikaDark", "paprikaDeep", "thunder", "thunderLight", "salem", "salemLight"].map((t) => ({ value: t, label: t }));
const LABEL_KEYS = ["homeEmotionCooking", "homeEmotionHosting", "homeEmotionJustSipping"].map((k) => ({ value: k, label: k }));
function HomeForm({ value, onChange }: Props) {
  const set = useSet(value, onChange);
  const tiles = arr<{ id: string; labelKey: string; icon: string; gradient: string[]; route: string }>(value.emotionTiles);
  return (
    <div className="stack" style={{ gap: 16 }}>
      <Section title="Emotion tiles" hint="The three tiles under the greeting. Labels come from the app's translations (label key); colours are palette tokens.">
        <ListEditor items={tiles} onChange={(v) => set("emotionTiles", v)} addLabel="Tile" blank={() => ({ id: "", labelKey: LABEL_KEYS[0].value, icon: "local_bar", gradient: ["paprika", "paprikaDeep"], route: "/pair" })} title={(t) => t.id || "New tile"}
          render={(t, upd) => (
            <div className="grid form">
              <Field label="ID"><TextInput value={t.id} onChange={(e) => upd({ id: camel(e.target.value) })} /></Field>
              <Field label="Label key"><Select value={t.labelKey} options={LABEL_KEYS} onChange={(labelKey) => upd({ labelKey })} /></Field>
              <Field label="Icon"><IconPicker value={t.icon} names={ICON_NAMES} onChange={(icon) => upd({ icon })} /></Field>
              <Field label="Opens"><TextInput value={t.route} onChange={(e) => upd({ route: e.target.value })} /></Field>
              <Field label="Gradient from"><Select value={t.gradient?.[0]} options={TOKENS} onChange={(g) => upd({ gradient: [g, t.gradient?.[1] ?? "paprikaDeep"] })} /></Field>
              <Field label="Gradient to"><Select value={t.gradient?.[1]} options={TOKENS} onChange={(g) => upd({ gradient: [t.gradient?.[0] ?? "paprika", g] })} /></Field>
            </div>
          )} />
      </Section>
      <Section title="Quick start" hint="Dish ids shown as chips under the Home decision launcher. Only dishes that exist in the catalogue are shown in the app.">
        <Field label="Dish ids (in order)"><Tags value={arr<string>(value.quickStart)} onChange={(v) => set("quickStart", v.map((x) => x.trim().toLowerCase()))} placeholder="e.g. butter-chicken" /></Field>
      </Section>
      <Section title="Actions" hint="Keep these off until a retail partner and a real reminder scheduler exist; the app shows the buttons as 'coming soon' meanwhile.">
        <Toggle checked={value.retailEnabled === true} onChange={(b) => set("retailEnabled", b)} label="Retail hand-off (Find to buy) enabled" />
        <Toggle checked={value.remindersEnabled === true} onChange={(b) => set("remindersEnabled", b)} label="Pick-up reminders enabled" />
      </Section>
      <Section title="Logo"><Field label="Asset path or URL"><TextInput value={str(value.logo)} onChange={(e) => set("logo", e.target.value)} /></Field></Section>
    </div>
  );
}

// ── Notifications ────────────────────────────────────────────────
function NotificationsForm({ value, onChange }: Props) {
  const set = useSet(value, onChange);
  const types = arr<{ code: string; deepLink: string }>(value.types);
  return (
    <Section title="Where each notification opens" hint="App routes, e.g. / (home), /profile, /feedback.">
      <div className="grid form">
        {types.map((t, i) => <Field key={t.code} label={t.code}><TextInput value={t.deepLink} onChange={(e) => set("types", types.map((x, j) => (j === i ? { ...x, deepLink: e.target.value } : x)))} /></Field>)}
      </div>
    </Section>
  );
}

export { Toggle };
