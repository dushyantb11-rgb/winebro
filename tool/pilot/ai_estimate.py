"""Pilot stage 4: AI taste estimates from sourced facts, in several rounds.

For each drink in tool/pilot/pilot_export.json (from export-pilot.js):

  Round 1  three independent estimates, each from a different angle
           (measured facts / style norms / comparison with scale anchors)
  Round 2  code: per-axis median and spread across the three, plus checks
           against hard facts (X-Wines body and acidity bands)
  Round 3  a reviewer call sees the facts, the three estimates and the
           check results, fixes contradictions and gives a confidence
           per axis
  Round 4  code: re-run the checks on the reviewed result; overall
           confidence = high / medium / low

The result is an *estimate from published facts*, not a tasting. It is
stored as `aiEstimate` with the inputs it used; a sommelier review is
still what makes a drink `verified`.

Usage (from app/):
  python tool/pilot/ai_estimate.py --dry-run --limit 1     print one prompt, no API call
  python tool/pilot/ai_estimate.py --limit 3               try 3 drinks
  python tool/pilot/ai_estimate.py                         all drinks
Needs: pip install -U anthropic  (ANTHROPIC_API_KEY in the environment)
"""
import argparse
import json
import statistics
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import date
from pathlib import Path

HERE = Path(__file__).parent
MODEL = "claude-opus-5"
AXES = ["fruit", "acidity", "body", "tannin", "freshness", "complexity"]
BANDS = {"Very light-bodied": (0, 3.5), "Light-bodied": (0, 3.5), "Medium-bodied": (3.5, 6.5),
         "Full-bodied": (6.5, 10), "Very full-bodied": (6.5, 10),
         "Low": (0, 3.5), "Medium": (3.5, 6.5), "High": (6.5, 10)}

SCALE = """WineBro taste axes, each an integer 0-10:
- fruit: how much fruit (and fruit sweetness) the drink shows. 0 = none, 10 = intensely fruity/sweet.
- acidity: sharpness and tang. 0 = flat/soft, 10 = very tart.
- body: weight in the mouth. 0 = watery-light, 10 = heavy and rich.
- tannin: grip, dryness, bitterness (grape tannin, oak, or hop bitterness for beer). 0 = none, 10 = very grippy/bitter.
- freshness: crisp, cool, lively feel. 0 = heavy/warm, 10 = very fresh.
- complexity: number and depth of flavours and how they develop. 0 = simple, 10 = very layered.
The same scale is used for wine, whisky, rum, brandy, vodka and beer, so a light lager and a
peated malt must sit sensibly against each other."""

ESTIMATE_SCHEMA = {
    "type": "object",
    "properties": {
        "tastingNotes": {"type": "string", "description": "2-3 sentences, own words, no quotes from critics"},
        "aromas": {"type": "array", "items": {"type": "string"}},
        **{a: {"type": "integer"} for a in AXES},
        "basis": {"type": "array", "items": {"type": "string"},
                  "description": "which given facts the estimate relies on"},
    },
    "required": ["tastingNotes", "aromas", *AXES, "basis"],
    "additionalProperties": False,
}
REVIEW_SCHEMA = {
    "type": "object",
    "properties": {
        **ESTIMATE_SCHEMA["properties"],
        "axisConfidence": {
            "type": "object",
            "properties": {a: {"type": "string", "enum": ["high", "medium", "low"]} for a in AXES},
            "required": AXES,
            "additionalProperties": False,
        },
        "changes": {"type": "array", "items": {"type": "string"},
                    "description": "what was fixed versus the three estimates, and why"},
    },
    "required": [*ESTIMATE_SCHEMA["required"], "axisConfidence", "changes"],
    "additionalProperties": False,
}

ANGLES = [
    "Work from the measured facts first: alcohol, residual sugar, acidity and body bands, "
    "grapes, beer style ranges. Let them decide the numbers wherever they speak.",
    "Work from style: what this grape, region, spirit type or beer style typically tastes like, "
    "and where this producer's line sits within it.",
    "Work by comparison: place this drink on each axis relative to the scale anchors given.",
]


def facts_text(d):
    lines = [f"Name: {d['name']}", f"Category: {d['category']}"]
    if d.get("brand"):
        lines.append(f"Brand: {d['brand']}")
    for k, v in (d.get("facts") or {}).items():
        if isinstance(v, dict) and "value" in v:
            lines.append(f"{k}: {v['value']}  (source: {v.get('source')})")
    od = d.get("openData") or {}
    x = od.get("xwines")
    if x:
        lines.append(f"X-Wines: ABV {x.get('abv')}, body {x.get('body')}, acidity {x.get('acidity')}, "
                     f"grapes {x.get('grapes')}, region {x.get('region')}, often paired with {x.get('pairsWith')}")
    b = od.get("bjcpStyle")
    if b:
        lines.append(f"BJCP style {b.get('styleId')} {b.get('name')}: ABV {b.get('abv')}, IBU {b.get('ibu')}, colour SRM {b.get('srm')}")
    off = od.get("openFoodFacts")
    if off and off.get("abv") is not None:
        lines.append(f"Open Food Facts ABV: {off['abv']}")
    w = (od.get("wikidata") or {})
    for role in ("producer", "product"):
        e = w.get(role)
        if e:
            lines.append(f"Wikidata {role}: {e.get('name')}, {e.get('country', '')}, founded {e.get('founded', '?')}")
    return "\n".join(lines)


def anchors_text(drinks):
    """A few catalogue drinks spread across categories, as the app's scale."""
    picks, seen = [], set()
    for d in drinks:
        c = d.get("catalog")
        if c and d["category"] not in seen:
            seen.add(d["category"])
            picks.append(f"- {d['name']} ({d['category']}): "
                         + ", ".join(f"{a} {c[a]:g}" for a in AXES))
    return ("Scale anchors (WineBro house scale, hand-set, not verified; use only to calibrate "
            "the scale, not as facts about other drinks):\n" + "\n".join(picks))


SYSTEM = """You estimate how drinks taste for WineBro, an Indian food-and-drink pairing app.
You have not tasted the drink. Base every number on the facts given and on well-established
style knowledge, say which facts you relied on, and never copy or quote critics' or retailers'
tasting notes. Write tasting notes in your own plain words for Indian drinkers.

""" + SCALE


def call(client, system, user, schema, effort):
    msg = client.beta.messages.create(
        model=MODEL,
        max_tokens=16000,
        betas=["server-side-fallback-2026-07-01"],
        fallbacks="default",
        thinking={"type": "adaptive"},
        output_config={"effort": effort, "format": {"type": "json_schema", "schema": schema}},
        system=system,
        messages=[{"role": "user", "content": user}],
    )
    if msg.stop_reason == "refusal":
        raise RuntimeError(f"refused: {getattr(msg.stop_details, 'category', None)}")
    if msg.stop_reason == "max_tokens":
        raise RuntimeError("hit max_tokens")
    text = next(b.text for b in msg.content if b.type == "text")
    return json.loads(text), msg.model


def clamp(v):
    return max(0, min(10, int(round(v))))


def check(d, est):
    """Hard-fact checks. Returns a list of plain-language violations."""
    out = []
    x = (d.get("openData") or {}).get("xwines") or {}
    for axis, key in (("body", "body"), ("acidity", "acidity")):
        band = BANDS.get(x.get(key))
        if band and not (band[0] - 0.5 <= est[axis] <= band[1] + 0.5):
            out.append(f"{axis} {est[axis]} is outside X-Wines '{x.get(key)}' ({band[0]}-{band[1]})")
    return out


def estimate_one(client, d, anchors):
    base = f"{anchors}\n\nDrink facts:\n{facts_text(d)}"
    samples = []
    for angle in ANGLES:
        est, _ = call(client, SYSTEM, f"{base}\n\nApproach: {angle}\nGive your estimate.",
                      ESTIMATE_SCHEMA, "medium")
        for a in AXES:
            est[a] = clamp(est[a])
        samples.append(est)

    median = {a: statistics.median(s[a] for s in samples) for a in AXES}
    spread = {a: max(s[a] for s in samples) - min(s[a] for s in samples) for a in AXES}
    pre = check(d, {a: clamp(median[a]) for a in AXES})

    review_prompt = (
        f"{base}\n\nThree independent estimates:\n{json.dumps(samples, ensure_ascii=False, indent=1)}\n\n"
        f"Per-axis median: {median}\nPer-axis spread (max-min): {spread}\n"
        f"Conflicts with hard facts: {pre or 'none'}\n\n"
        "Review as a careful sommelier would before tasting: resolve disagreements, fix anything that "
        "conflicts with the hard facts, keep the scale consistent with the anchors, and merge the best "
        "tasting notes. Rate your confidence per axis: high only when the facts pin it down or all "
        "three agree within 1; low when they disagree by 3 or more and no fact settles it."
    )
    final, model_used = call(client, SYSTEM, review_prompt, REVIEW_SCHEMA, "high")
    for a in AXES:
        final[a] = clamp(final[a])
    post = check(d, final)

    lows = sum(1 for a in AXES if final["axisConfidence"][a] == "low")
    if post or lows >= 2 or max(spread.values()) >= 4:
        overall = "low"
    elif lows == 0 and max(spread.values()) <= 2:
        overall = "high"
    else:
        overall = "medium"

    return {
        **final,
        "confidence": overall,
        "rounds": {"samples": samples, "median": median, "spread": spread,
                   "conflictsBeforeReview": pre, "conflictsAfterReview": post},
        "model": model_used,
        "method": "3 independent estimates + reviewer pass + fact checks",
        "inputs": facts_text(d),
        "date": date.today().isoformat(),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--limit", type=int)
    ap.add_argument("--only", nargs="*", help="drink ids")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--workers", type=int, default=6)
    a = ap.parse_args()

    drinks = json.load(open(HERE / "pilot_export.json", encoding="utf-8"))
    anchors = anchors_text(drinks)
    todo = [d for d in drinks if not a.only or d["id"] in a.only][: a.limit]

    if a.dry_run:
        d = todo[0]
        print(SYSTEM, "\n---\n", anchors, "\n\nDrink facts:\n", facts_text(d), sep="")
        return

    import anthropic
    client = anthropic.Anthropic()
    out_path = HERE / "ai_estimates.json"
    results = json.load(open(out_path, encoding="utf-8")) if out_path.exists() else {}

    with ThreadPoolExecutor(max_workers=a.workers) as pool:
        futures = {pool.submit(estimate_one, client, d, anchors): d["id"] for d in todo}
        for f in as_completed(futures):
            pid = futures[f]
            try:
                results[pid] = f.result()
                r = results[pid]
                print(f"{pid:36} {r['confidence']:6} " + " ".join(f"{x[:3]}{r[x]}" for x in AXES))
            except Exception as e:  # keep going; report at the end
                print(f"{pid:36} FAILED {e}", file=sys.stderr)
            json.dump(results, open(out_path, "w", encoding="utf-8"), ensure_ascii=False, indent=1)

    from collections import Counter
    print("confidence:", dict(Counter(r["confidence"] for r in results.values())))


if __name__ == "__main__":
    main()
