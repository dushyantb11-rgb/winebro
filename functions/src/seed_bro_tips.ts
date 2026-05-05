/**
 * Daily Bro Tip catalogue. Tagged by [PalateArchetype] from the Dart
 * domain. Each archetype gets ~6 tips it's particularly suited to;
 * `general` tips work for everyone.
 *
 * The CF-06 dailyBroTipPush picks one tip per archetype-cohort each
 * day. Keep this list under ~50 entries for v1.0; rotate seasonally.
 */
export interface BroTip {
  id: string;
  /** Single sentence pull-quote. ≤ 120 chars to fit a push notification body. */
  body: string;
  /** Optional pithy supporting line; rendered on tap, not in the push. */
  detail?: string;
  /** Archetype this tip resonates with most. "general" hits all users. */
  archetype:
    | "general"
    | "boldExplorer"
    | "crispPurist"
    | "fruitForward"
    | "balancedSipper"
    | "sweetTooth";
}

export const BRO_TIPS: BroTip[] = [
  {
    id: "spicy-food-offdry",
    body: "Spicy Indian food? Reach for an off-dry Riesling or fruity Rosé — the residual sugar tames the heat.",
    detail: "High-tannin reds amplify the burn. Avoid them.",
    archetype: "general",
  },
  {
    id: "decant-young-red",
    body: "Young red feeling sharp? Decant it for 30 minutes — air softens tannins and unlocks the fruit.",
    archetype: "boldExplorer",
  },
  {
    id: "white-temp",
    body: "White wine straight from the fridge is too cold. Take it out 15 min before pouring.",
    detail: "Below 8°C dulls the aromas. Sweet spot: 10-12°C.",
    archetype: "crispPurist",
  },
  {
    id: "biryani-rose",
    body: "Biryani night? Indian Rosé is the sleeper hit — handles spice, fat, and aromatics in one glass.",
    archetype: "fruitForward",
  },
  {
    id: "whisky-water",
    body: "A splash of water in your single malt isn't dilution — it opens new aromas. Try it before you judge it.",
    archetype: "boldExplorer",
  },
  {
    id: "dosa-beer",
    body: "Masala dosa? Skip wine. A clean lager or wheat beer cuts through ghee far better.",
    archetype: "balancedSipper",
  },
  {
    id: "dessert-fortified",
    body: "Pair sweet desserts with sweeter wine. Fortified Port or a late-harvest Riesling beats dry every time.",
    archetype: "sweetTooth",
  },
  {
    id: "tandoori-shiraz",
    body: "Tandoori chicken loves Shiraz. The pepper notes echo each other; the smoke rounds out the wine.",
    archetype: "boldExplorer",
  },
  {
    id: "store-vertical",
    body: "Store wine bottles on their side. Keeps the cork moist; dry corks let in air and ruin the wine.",
    archetype: "general",
  },
  {
    id: "aroma-swirl",
    body: "Swirl before you sniff. The aromas live in the headspace, not the liquid.",
    archetype: "general",
  },
  {
    id: "sweet-pair-sweeter",
    body: "Cardinal rule: the wine must be sweeter than the dessert. Otherwise the wine tastes flat.",
    archetype: "sweetTooth",
  },
  {
    id: "fish-light-white",
    body: "Light fish + heavy wine = ruined fish. Stick to crisp whites under 12% ABV with delicate seafood.",
    archetype: "crispPurist",
  },
  {
    id: "rum-neat",
    body: "Premium rum (Old Monk XXX, McDowell's No.1 Single Barrel) deserves a neat pour. Mixers are for the cheap stuff.",
    archetype: "boldExplorer",
  },
  {
    id: "pizza-chianti",
    body: "Margherita pizza wants Chianti — the acidity slices through cheese, tomato gets a lift.",
    archetype: "balancedSipper",
  },
  {
    id: "gin-tonic-glass",
    body: "G&T in a balloon glass, not a highball. The bowl traps the botanicals — completely different drink.",
    archetype: "crispPurist",
  },
  {
    id: "indian-wine-young",
    body: "Most Indian wines are made for the year they're released. Don't cellar them — drink them young, fresh, fruity.",
    archetype: "fruitForward",
  },
  {
    id: "paneer-rose-shiraz",
    body: "Paneer-based curries split your options: cream-base wants Rosé, gravy-base wants Shiraz.",
    archetype: "general",
  },
  {
    id: "single-malt-water-temp",
    body: "Single malt at room temperature. Ice numbs the palate; water at 1:5 ratio brings out the cask character.",
    archetype: "boldExplorer",
  },
  {
    id: "sparkling-cold",
    body: "Sparkling wine at 6-8°C. Warmer than that and the bubbles flatten in your glass within minutes.",
    archetype: "crispPurist",
  },
  {
    id: "red-meat-tannin",
    body: "Steak + Cabernet is a cliché because it works. Tannins bind to protein and soften — the wine tastes smoother.",
    archetype: "boldExplorer",
  },
  {
    id: "moscato-fruit",
    body: "Moscato d'Asti with fresh fruit and Indian sweets — the pairing nobody talks about. Try it once.",
    archetype: "sweetTooth",
  },
  {
    id: "decant-old-red",
    body: "30+ year old red? Decant carefully — sediment at the bottom. Pour gently, leave the last 1cm.",
    archetype: "boldExplorer",
  },
  {
    id: "vermouth-fridge",
    body: "Open vermouth lasts ~6 weeks in the fridge. After that it oxidises. Don't use it neat past that point.",
    archetype: "general",
  },
  {
    id: "rosé-misjudge",
    body: "Indian Rosé is criminally underrated. Pairs with chaat, biryani, paneer, tandoori — the most versatile bottle in the country.",
    archetype: "fruitForward",
  },
  {
    id: "balanced-blend",
    body: "Bordeaux blend (Cab + Merlot + Cab Franc) is the sommelier's safe pick. Works with anything; offends nobody.",
    archetype: "balancedSipper",
  },
  {
    id: "summer-light",
    body: "Indian summer? Lower the alcohol, lift the freshness. Sub-12% ABV whites + dry Rosés are your best friends.",
    archetype: "crispPurist",
  },
  {
    id: "cheese-board-port",
    body: "Cheese board pairing: Stilton + Port. The salty-sweet contrast is the most famous pairing in the wine world.",
    archetype: "sweetTooth",
  },
  {
    id: "napa-cab",
    body: "Napa Cabernet ages 8-15 years. Indian climate accelerates that — drink within 5-7 years for peak.",
    archetype: "boldExplorer",
  },
  {
    id: "open-bottle-storage",
    body: "Half-finished bottle? Re-cork, fridge, drink in 3 days. After that it's vinegar with extra steps.",
    archetype: "general",
  },
  {
    id: "label-trust",
    body: "Trust the label. If a wine says 'Reserve' it's usually aged longer with more complexity — worth the markup.",
    archetype: "balancedSipper",
  },
];

export function pickTipForArchetype(
  archetype: BroTip["archetype"],
  daySeed: number
): BroTip {
  const candidates = BRO_TIPS.filter(
    (t) => t.archetype === archetype || t.archetype === "general"
  );
  return candidates[daySeed % candidates.length];
}
