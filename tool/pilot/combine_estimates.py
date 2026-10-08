"""Rounds 2 and 4 of the pilot taste estimates (code, no AI).

round2: reads estimates_angle1..3.json (three independent estimators) and
        pilot_export.json, computes per-axis median and spread, checks the
        median against hard facts, and writes review_input.txt for the
        reviewer plus round2.json.
final:  reads estimates_review.json (the reviewer's result), re-checks hard
        facts, sets overall confidence, and writes ai_estimates.json.

Usage (from app/):
  python tool/pilot/combine_estimates.py round2
  python tool/pilot/combine_estimates.py final
"""
import json
import statistics
import sys
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from ai_estimate import AXES, check, facts_text  # noqa: E402

HERE = Path(__file__).parent


def load(name):
    return json.load(open(HERE / name, encoding="utf-8"))


def round2():
    drinks = {d["id"]: d for d in load("pilot_export.json")}
    angles = [load(f"estimates_angle{i}.json") for i in (1, 2, 3)]
    out, lines = {}, []
    for pid, d in sorted(drinks.items()):
        samples = [a[pid] for a in angles if pid in a]
        if len(samples) < 3:
            print(f"missing samples for {pid}: {len(samples)}")
        median = {ax: statistics.median(int(s[ax]) for s in samples) for ax in AXES}
        spread = {ax: max(int(s[ax]) for s in samples) - min(int(s[ax]) for s in samples) for ax in AXES}
        conflicts = check(d, {ax: round(median[ax]) for ax in AXES})
        out[pid] = {"samples": samples, "median": median, "spread": spread, "conflicts": conflicts}
        lines.append(
            f"\n## id: {pid}\n{facts_text(d)}\n"
            + "\n".join(f"Estimate {i + 1}: " + ", ".join(f"{ax} {s[ax]}" for ax in AXES)
                        + f" | notes: {s['tastingNotes']} | aromas: {', '.join(s['aromas'])}"
                        for i, s in enumerate(samples))
            + "\nMedian: " + ", ".join(f"{ax} {median[ax]:g}" for ax in AXES)
            + "\nSpread: " + ", ".join(f"{ax} {spread[ax]}" for ax in AXES)
            + f"\nConflicts with hard facts: {conflicts or 'none'}"
        )
    json.dump(out, open(HERE / "round2.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    head = open(HERE / "agent_input.txt", encoding="utf-8").read().split("=== DRINKS ===")[0]
    open(HERE / "review_input.txt", "w", encoding="utf-8").write(head + "=== DRINKS WITH THREE ESTIMATES ===" + "".join(lines))
    big = sum(1 for v in out.values() if max(v["spread"].values()) >= 3)
    print(f"{len(out)} drinks | spread >= 3 on some axis: {big} | fact conflicts: "
          f"{sum(1 for v in out.values() if v['conflicts'])}")


def final():
    drinks = {d["id"]: d for d in load("pilot_export.json")}
    r2 = load("round2.json")
    review = load("estimates_review.json")
    out = {}
    for pid, rv in review.items():
        d = drinks[pid]
        for ax in AXES:
            rv[ax] = max(0, min(10, int(round(rv[ax]))))
        post = check(d, rv)
        spread = r2[pid]["spread"]
        lows = sum(1 for ax in AXES if rv["axisConfidence"][ax] == "low")
        # The three estimators are the same model, so their agreement shows
        # consistency, not accuracy. "high" also needs a hard taste fact.
        od = d.get("openData") or {}
        x = od.get("xwines") or {}
        taste_facts = [k for k, ok in (("X-Wines body", x.get("body")),
                                       ("X-Wines acidity", x.get("acidity")),
                                       ("BJCP style", od.get("bjcpStyle"))) if ok]
        if post or lows >= 2 or max(spread.values()) >= 3:
            overall = "low"
        elif lows == 0 and max(spread.values()) <= 1 and taste_facts:
            overall = "high"
        else:
            overall = "medium"
        out[pid] = {
            **rv,
            "confidence": overall,
            "tasteFactsUsed": taste_facts,
            "rounds": {**r2[pid], "conflictsAfterReview": post},
            "method": "3 independent estimates + reviewer pass + fact checks",
            "label": "Estimated from published facts",
            "inputs": facts_text(d),
            "date": date.today().isoformat(),
        }
    json.dump(out, open(HERE / "ai_estimates.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    from collections import Counter
    print(f"{len(out)} estimates | confidence {dict(Counter(v['confidence'] for v in out.values()))} | "
          f"fact conflicts left {sum(1 for v in out.values() if v['rounds']['conflictsAfterReview'])}")


if __name__ == "__main__":
    {"round2": round2, "final": final}[sys.argv[1]]()
