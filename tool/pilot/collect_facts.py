"""Collect sourced facts for the data pilot (stage 2).

Reads app/tool/pilot/pilot_list.json and writes app/tool/pilot/facts.json:
    { drinkId: { field: {value, source, url, date, note?}, ... }, ... }

Sources (download locally, pass the paths):
  --ksbcl  KSBCL Karnataka "supplier wise item wise pricing" PDF
  --bevco  Kerala BEVCO "price list of Indian made items" PDF
  --xwines X-Wines XWines_Full_100K_wines.csv (CC0)

What each source is trusted for:
  KSBCL   official product name, supplier in Karnataka, pack sizes sold.
  BEVCO   wine ABV from the declared proof (proof x 4/7). NOT used for
          beer or spirits: there every item shows its excise band
          (beer 5.0/6.0%, spirits 42.86%), not the label strength.
  X-Wines ABV, grapes, region, body, acidity, food pairings, for wines
          matched by hand (X-Wines id in pilot_list reasonDetail).

Usage (from app/):
  python tool/pilot/collect_facts.py --ksbcl <pdf> --bevco <pdf> --xwines <csv>
Needs: pip install pymupdf
"""
import argparse
import csv
import json
import re
from pathlib import Path

import fitz  # pymupdf

HERE = Path(__file__).parent
KSBCL_URL = ("https://ksbcl.karnataka.gov.in/uploads/supplier%20wise%20item%20wise"
             "%20pricing%20details%20as%20on%2031_1789544043.pdf")
BEVCO_URL = ("https://bevco.in/wp-content/uploads/REPORTS/2024/01/PRICE%20LIST/"
             "PRICE-LIST___19-01-2024_PRICE-LIST-OF-INDIAN-MADE-ITEMS-W.E.F-19-01-2024.pdf")
XWINES_URL = "https://github.com/rogerioxavier/X-Wines"
WINE_CATEGORIES = {"redWine", "whiteWine", "roseWine", "sparklingWine", "dessertWine"}
GENERIC = {"the", "and", "of", "wine", "wines", "red", "white", "vineyards", "vineyard",
           "beer", "premium", "deluxe", "whisky", "brandy", "rum", "vodka", "seagram", "s",
           "zampa"}


def words(text):
    t = text.lower().replace("é", "e").replace("ç", "c").replace("ñ", "n")
    return [w for w in re.split(r"[^a-z0-9]+", t) if w]


def fact(value, source, url, date, note=None):
    f = {"value": value, "source": source, "url": url, "date": date}
    if note:
        f["note"] = note
    return f


def parse_ksbcl(path):
    lines = [l.strip() for p in fitz.open(path) for l in p.get_text().split("\n")]
    rows, supplier, i = [], None, 0
    while i < len(lines):
        m = re.match(r"^\d+\s+Supplier\s*:\s*(.+)$", lines[i])
        if m:
            supplier = re.sub(r"\s*\(\d{4}\)$", "", m.group(1)).strip()
            i += 1
            continue
        m = re.match(r"^\d+\s+(.+\(\d{4}\))$", lines[i])
        if (m and i + 2 < len(lines) and re.match(r"^\d{6,}$", lines[i + 1])
                and re.match(r"^\d{1,2}-[A-Za-z]{3}-\d{2}$", lines[i + 2])):
            raw = m.group(1)
            ml = re.search(r"(\d+)\s*ML", raw, re.I)
            name = re.sub(r"\(\d{4}\)$", "", raw)
            name = re.sub(r"\s*[-–]?\s*\d+\s*ML.*$", "", name, flags=re.I).strip(" -.")
            rows.append({"name": name, "code": lines[i + 1], "effective": lines[i + 2],
                         "ml": int(ml.group(1)) if ml else None, "supplier": supplier})
            i += 3
            continue
        i += 1
    return rows


def parse_bevco(path):
    lines = [l.strip() for p in fitz.open(path) for l in p.get_text().split("\n")]
    rows, category = [], None
    for i, l in enumerate(lines):
        if l in ("IMFL", "BEER", "WINE"):
            category = l
        m = re.match(r"^(\d{8}[A-Z]?)\s+(.+)$", l)
        if m and i + 3 < len(lines):
            ml, case, proof = lines[i + 1], lines[i + 2], lines[i + 3]
            if (re.match(r"^\d+$", ml) and re.match(r"^\d+$", case)
                    and re.match(r"^\d+(\.\d+)?$", proof)):
                rows.append({"code": m.group(1), "name": m.group(2).strip(), "ml": int(ml),
                             "proof": float(proof), "category": category})
    return rows


def best_name_match(target, candidates, key="name"):
    """Exact word-set match after dropping generic words, so "Dindori
    Reserve Viognier" never matches "Dindori Reserve Shiraz" and
    "Sula Shiraz" never matches "Sula Shiraz Cabernet"."""
    tw = set(words(target)) - GENERIC
    if not tw:
        return None
    for c in candidates:
        if set(words(c[key])) - GENERIC == tw:
            return c
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ksbcl", required=True)
    ap.add_argument("--bevco", required=True)
    ap.add_argument("--xwines", required=True)
    a = ap.parse_args()

    pilot = json.load(open(HERE / "pilot_list.json", encoding="utf-8"))["drinks"]
    ksbcl = parse_ksbcl(a.ksbcl)
    bevco = parse_bevco(a.bevco)
    bevco_wine = [r for r in bevco if r["category"] == "WINE" and r["ml"] == 750]
    xwines = {r["WineID"]: r for r in csv.DictReader(open(a.xwines, encoding="utf-8"))}

    facts, review = {}, []
    for d in pilot:
        f = {}
        k = d.get("ksbcl")
        if k:
            sizes = sorted({r["ml"] for r in ksbcl
                            if r["name"].lower() == k["officialName"].lower() and r["ml"]})
            f["officialName"] = fact(k["officialName"], "KSBCL Karnataka price list",
                                     KSBCL_URL, k["effective"], f"item code {k['itemCode']}")
            f["supplierKarnataka"] = fact(k["supplier"], "KSBCL Karnataka price list",
                                          KSBCL_URL, k["effective"])
            f["packSizesMl"] = fact(sizes, "KSBCL Karnataka price list", KSBCL_URL, k["effective"])

        if d["category"] in WINE_CATEGORIES:
            b = best_name_match(d["name"], bevco_wine)
            if b:
                f["abvKerala"] = fact(round(b["proof"] * 4 / 7, 1), "Kerala BEVCO price list (declared proof)",
                                      BEVCO_URL, "2024-01-19", f"{b['name']}, proof {b['proof']}")
                review.append((d["id"], d["name"], b["name"]))
            xid = re.search(r"X-Wines (\d+)", d.get("reasonDetail") or "")
            x = xwines.get(xid.group(1)) if xid else None
            if x:
                f["abvXWines"] = fact(float(x["ABV"]), "X-Wines (CC0)", XWINES_URL, "2022")
                f["grapes"] = fact(re.findall(r"'([^']*)'", x["Grapes"]), "X-Wines (CC0)", XWINES_URL, "2022")
                f["region"] = fact(x["RegionName"], "X-Wines (CC0)", XWINES_URL, "2022")
                f["bodyXWines"] = fact(x["Body"], "X-Wines (CC0)", XWINES_URL, "2022")
                f["acidityXWines"] = fact(x["Acidity"], "X-Wines (CC0)", XWINES_URL, "2022")
                f["pairsWithXWines"] = fact(re.findall(r"'([^']*)'", x["Harmonize"]),
                                            "X-Wines (CC0)", XWINES_URL, "2022")
        facts[d["id"]] = f

    producer = json.load(open(HERE / "producer_facts.json", encoding="utf-8"))
    for pid, extra in producer.items():
        if pid in facts:
            facts[pid].update(extra)

    out = HERE / "facts.json"
    json.dump(facts, open(out, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    have = lambda key: sum(1 for v in facts.values() if key in v)
    print(f"{len(facts)} drinks | officialName {have('officialName')} | abvKerala {have('abvKerala')}"
          f" | X-Wines {have('abvXWines')}")
    print("Kerala wine matches to review:")
    for r in review:
        print("  ", r[0], "|", r[1], "->", r[2])


if __name__ == "__main__":
    main()
