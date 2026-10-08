import 'package:flutter/material.dart';

/// Icons the remote config may refer to by name. The admin picks from
/// this list; the app never resolves arbitrary icon names.
const kIconRegistry = <String, IconData>{
  'air': Icons.air,
  'arrow_forward': Icons.arrow_forward,
  'arrow_forward_ios': Icons.arrow_forward_ios,
  'assignment': Icons.assignment,
  'balance': Icons.balance,
  'beach_access': Icons.beach_access,
  'bolt': Icons.bolt,
  'book_outlined': Icons.book_outlined,
  'breakfast_dining': Icons.breakfast_dining,
  'brunch_dining': Icons.brunch_dining,
  'business_center': Icons.business_center,
  'cake': Icons.cake,
  'casino': Icons.casino,
  'celebration': Icons.celebration,
  'celebration_outlined': Icons.celebration_outlined,
  'coffee': Icons.coffee,
  'diamond': Icons.diamond,
  'dining': Icons.dining,
  'eco': Icons.eco,
  'edit': Icons.edit,
  'emoji_events': Icons.emoji_events,
  'emoji_events_outlined': Icons.emoji_events_outlined,
  'explore': Icons.explore,
  'fastfood': Icons.fastfood,
  'fitness_center': Icons.fitness_center,
  'flag': Icons.flag,
  'grain': Icons.grain,
  'handshake': Icons.handshake,
  'kebab_dining': Icons.kebab_dining,
  'lightbulb_outline': Icons.lightbulb_outline,
  'liquor': Icons.liquor,
  'local_bar': Icons.local_bar,
  'local_cafe': Icons.local_cafe,
  'local_drink': Icons.local_drink,
  'local_fire_department': Icons.local_fire_department,
  'local_florist': Icons.local_florist,
  'lunch_dining': Icons.lunch_dining,
  'menu_book': Icons.menu_book,
  'military_tech': Icons.military_tech,
  'nightlife': Icons.nightlife,
  'nightlight_round': Icons.nightlight_round,
  'outdoor_grill': Icons.outdoor_grill,
  'park': Icons.park,
  'people_outline': Icons.people_outline,
  'photo_camera': Icons.photo_camera,
  'replay_circle_filled_rounded': Icons.replay_circle_filled_rounded,
  'restaurant': Icons.restaurant,
  'restaurant_menu_outlined': Icons.restaurant_menu_outlined,
  'rice_bowl': Icons.rice_bowl,
  'set_meal': Icons.set_meal,
  'shopping_bag_outlined': Icons.shopping_bag_outlined,
  'soup_kitchen': Icons.soup_kitchen,
  'spa': Icons.spa,
  'sports_bar': Icons.sports_bar,
  'star': Icons.star,
  'track_changes': Icons.track_changes,
  'visibility': Icons.visibility,
  'water_drop': Icons.water_drop,
  'weekend': Icons.weekend,
  'whatshot': Icons.whatshot,
  'wine_bar': Icons.wine_bar,
};

final Map<int, String> _byCodePoint = {
  for (final e in kIconRegistry.entries) e.value.codePoint: e.key,
};

/// Registry name of [icon], or null when it is not in the registry.
String? iconName(IconData icon) => _byCodePoint[icon.codePoint];

/// Icon for a registry [name]; [fallback] when the name is unknown.
IconData iconFor(String? name, {IconData fallback = Icons.local_bar}) =>
    kIconRegistry[name] ?? fallback;
