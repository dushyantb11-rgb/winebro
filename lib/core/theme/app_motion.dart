import 'package:flutter/animation.dart';

/// Motion design tokens for WineBro.
///
/// Three primitives carry the entire app:
///   springGentle  — for tab swaps, sheet slides, theme transitions
///   springBouncy  — for delight moments (badge unlock, scan match)
///   tickerCount   — for animated number counters (XP, scans, stats)
///
/// Plus a haptic policy that screens consume directly via HapticFeedback.
abstract final class AppMotion {
  AppMotion._();

  // Durations
  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration gentle = Duration(milliseconds: 350);
  static const Duration bouncy = Duration(milliseconds: 500);
  static const Duration ticker = Duration(milliseconds: 800);
  static const Duration cinematic = Duration(milliseconds: 1200);

  // Curves
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;

  /// Overshoot spring for delight moments. Hits ~110% then settles.
  static const Curve spring = Cubic(0.34, 1.56, 0.64, 1);

  /// Slow exit. Use when the screen is leaving, not arriving.
  static const Curve exit = Curves.easeInCubic;
}
