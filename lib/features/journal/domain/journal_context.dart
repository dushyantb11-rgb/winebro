import 'package:flutter/material.dart';

/// Where / why the user was drinking. Persisted to
/// `JournalEntry.occasion` (free-form String) using these codes.
///
/// D10 "Occasion-context patterns" — every saved BroCard / Quick-log
/// adds one row to the cohort: home tasting vs out vs travel.
/// Year-1 target: 3,000 occasion-tagged entries.
///
/// Distinct from `core/constants/pairing_constants.Occasion` which is
/// the pairing-engine context modifier (Date Night, BBQ, etc.).
/// That's about *what* they want; this is about *where they are*.
enum JournalContext {
  home(code: 'home', icon: Icons.home_outlined),
  restaurant(code: 'restaurant', icon: Icons.restaurant_outlined),
  bar(code: 'bar', icon: Icons.local_bar_outlined),
  party(code: 'party', icon: Icons.celebration_outlined),
  travel(code: 'travel', icon: Icons.flight_outlined),
  other(code: 'other', icon: Icons.more_horiz);

  const JournalContext({required this.code, required this.icon});
  final String code;
  final IconData icon;

  static JournalContext? fromCode(String? c) {
    if (c == null || c.isEmpty) return null;
    return JournalContext.values.firstWhere(
      (j) => j.code == c,
      orElse: () => JournalContext.other,
    );
  }
}
