import { useQuery } from "@tanstack/react-query";
import { api, Doc } from "./api";

export type ConfigMap = Record<string, Doc>;

export function useConfigAll() {
  return useQuery({
    queryKey: ["config"],
    queryFn: async () => {
      const docs = await api.configAll();
      const map: ConfigMap = {};
      for (const d of docs) map[d.id] = d;
      return map;
    },
  });
}

export type Option = { value: string; label: string };

function items(cfg: ConfigMap | undefined, doc: string, key: string): Record<string, unknown>[] {
  const v = cfg?.[doc]?.[key];
  return Array.isArray(v) ? (v as Record<string, unknown>[]) : [];
}

/** Option lists the forms use, by name (see schema `options`). */
export function optionLists(cfg: ConfigMap | undefined): Record<string, Option[]> {
  const opt = (doc: string, key: string, code = "code", label = "displayName"): Option[] =>
    items(cfg, doc, key).map((i) => ({ value: String(i[code]), label: String(i[label] ?? i[code]) }));
  return {
    drinks: opt("categories", "drinks"),
    cuisines: opt("categories", "cuisines"),
    foodProperties: opt("categories", "foodProperties"),
    archetypes: opt("archetypes", "items"),
    occasions: opt("occasions", "items"),
    strategies: opt("categories", "pairingStrategies"),
    axes: opt("categories", "palateAxes"),
  };
}

export const CONFIG_DOCS: { id: string; title: string; icon: string; blurb: string }[] = [
  { id: "pairingRules", title: "Pairing rules", icon: "tune", blurb: "How drinks are scored for a dish, a palate and an occasion; Bro-tip wording." },
  { id: "archetypes", title: "Palate archetypes", icon: "psychology", blurb: "The palate types, their bonus and the rules that decide who is which." },
  { id: "quiz", title: "Taste quiz", icon: "quiz", blurb: "Quiz steps, answers and the points each answer adds to the six taste axes." },
  { id: "scanner", title: "Label scanner", icon: "document_scanner", blurb: "Match thresholds and words to ignore when reading a label." },
  { id: "gamification", title: "XP and levels", icon: "military_tech", blurb: "XP per action and the level ladder." },
  { id: "badges", title: "Badges", icon: "workspace_premium", blurb: "Every badge, its reward and the condition to earn it." },
  { id: "categories", title: "Categories and lists", icon: "category", blurb: "Drink categories and groups, cuisines, food properties, strategies, axis names." },
  { id: "occasions", title: "Occasions", icon: "celebration", blurb: "Occasions, their icons, taste nudges and category bonus." },
  { id: "journalScales", title: "Journal scales", icon: "menu_book", blurb: "Pick lists used in a BroCard (reference)." },
  { id: "aromaWheel", title: "Aroma wheel", icon: "air", blurb: "Aroma families, sub-families and aromas, plus Indian terms." },
  { id: "home", title: "Home screen", icon: "home", blurb: "Emotion tiles and logo." },
  { id: "notifications", title: "Notifications", icon: "notifications", blurb: "Where each push notification opens in the app." },
];
