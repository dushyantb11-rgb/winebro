// Icon names the app can render (lib/core/config/icon_registry.dart).
// Previewed here with the Material Symbols font (same glyph family).
export const ICON_NAMES = [
  "air", "arrow_forward", "arrow_forward_ios", "assignment", "balance", "beach_access",
  "bolt", "book_outlined", "breakfast_dining", "brunch_dining", "business_center", "cake",
  "casino", "celebration", "celebration_outlined", "coffee", "diamond", "dining", "eco",
  "edit", "emoji_events", "emoji_events_outlined", "explore", "fastfood", "fitness_center",
  "flag", "grain", "handshake", "kebab_dining", "lightbulb_outline", "liquor", "local_bar",
  "local_cafe", "local_drink", "local_fire_department", "local_florist", "lunch_dining",
  "menu_book", "military_tech", "nightlife", "nightlight_round", "outdoor_grill", "park",
  "people_outline", "photo_camera", "replay_circle_filled_rounded", "restaurant",
  "restaurant_menu_outlined", "rice_bowl", "set_meal", "shopping_bag_outlined",
  "soup_kitchen", "spa", "sports_bar", "star", "track_changes", "visibility", "water_drop",
  "weekend", "whatshot", "wine_bar",
] as const;

/** Material Symbols ligature for an app icon name. */
export function symbol(name: string | undefined): string {
  if (!name) return "circle";
  return name
    .replace(/_(outlined|rounded|filled)$/, "")
    .replace(/^lightbulb_outline$/, "lightbulb")
    .replace(/^replay_circle_filled$/, "replay_circle_filled")
    .replace(/^nightlight$/, "nightlight");
}
