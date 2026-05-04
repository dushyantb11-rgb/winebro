import 'package:flutter/material.dart';

/// Elevation system for WineBro. Light theme uses soft drop shadows,
/// dark theme uses paprika-tinted shadows + inner highlight rings to
/// keep cards readable against the cellar-dark background.
///
/// Four levels:
///   e0     — flat (background)
///   e1     — cards, list items
///   e2     — floating buttons, sticky chrome
///   eHero  — Bro's Pick, BroCards, Tonight's Pour
abstract final class AppElevation {
  AppElevation._();

  static List<BoxShadow> e1({required bool dark}) {
    return dark
        ? const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ];
  }

  static List<BoxShadow> e2({required bool dark}) {
    return dark
        ? const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ];
  }

  /// Hero-level lift. Cinematic. Use sparingly — one per screen.
  static List<BoxShadow> eHero({required bool dark}) {
    return dark
        ? const [
            BoxShadow(
              color: Color(0xB3000000),
              blurRadius: 80,
              offset: Offset(0, 32),
            ),
            BoxShadow(
              color: Color(0x33930044),
              blurRadius: 40,
              spreadRadius: -8,
              offset: Offset(0, 16),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x2E93003C),
              blurRadius: 60,
              offset: Offset(0, 24),
            ),
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ];
  }

  /// Inner highlight ring used on dark cards to prevent them disappearing
  /// into the charcoal background. Apply via Border, not BoxShadow.
  static const Border darkInnerRing = Border.fromBorderSide(
    BorderSide(color: Color(0x0AFFFFFF)),
  );
}
