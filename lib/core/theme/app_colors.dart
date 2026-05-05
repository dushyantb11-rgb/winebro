import 'package:flutter/material.dart';

/// WineBro color tokens. Brand-locked: paprika #93003C, salem #0F8044,
/// thunder #252122. Everything else is supporting cast.
///
/// Token tiers:
///   Brand        paprika / paprikaLight / paprikaDark / paprikaDeep
///                salem / salemLight
///                gold / goldLight / goldDark / goldWarm
///   Surfaces     charcoal (background) / surface1..4 (lift levels)
///   Text         textPrimary / textSecondary / textTertiary
///   Borders      borderSubtle / borderDefault / borderStrong
///   Status       success / warning / error / info
///   Cinematic    inkOnHero (always white) / scrim (photo overlay)
///   Chrome       navBarBackground / charcoalDeep
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.paprika,
    required this.paprikaLight,
    required this.paprikaDark,
    required this.paprikaDeep,
    required this.thunder,
    required this.thunderLight,
    required this.salem,
    required this.salemLight,
    required this.gold,
    required this.goldLight,
    required this.goldDark,
    required this.goldWarm,
    required this.charcoal,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.surface4,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.charcoalDeep,
    required this.navBarBackground,
    required this.inkOnHero,
    required this.scrim,
  });

  final Color paprika;
  final Color paprikaLight;
  final Color paprikaDark;

  /// Deepest paprika. Use for hero gradients, premium card backs,
  /// shadow tints. Reads as "9pm wine bar."
  final Color paprikaDeep;

  final Color thunder;
  final Color thunderLight;
  final Color salem;
  final Color salemLight;
  final Color gold;
  final Color goldLight;
  final Color goldDark;

  /// Warm champagne gold. Use for VIP / Bro's Pick ribbons and
  /// hero badges. Less "highlighter" than [gold], more "single malt."
  final Color goldWarm;

  final Color charcoal;
  final Color surface1;
  final Color surface2;
  final Color surface3;
  final Color surface4;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;

  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  final Color charcoalDeep;
  final Color navBarBackground;

  /// Always white. Use for text on cinematic dark photography
  /// regardless of active theme.
  final Color inkOnHero;

  /// Photo scrim. Stronger in dark to keep text readable against
  /// brighter mid-tones in photography.
  final Color scrim;

  // CHV brand guide v1.0 (WineBro venture):
  //   Primary palette: Paprika #93003C, Thunder #252122, Salem #0F8044
  //   Secondary palette: Paprika, White, Salem
  // No gold/champagne. Any "gold-equivalent" highlight must be White
  // (on dark backgrounds) or Paprika (on light backgrounds).
  // The gold/goldLight/goldDark/goldWarm tokens are kept as aliases
  // so the rest of the codebase compiles, but they all resolve to
  // brand-legal colors:
  //   gold      -> Paprika   (highlight color on light surfaces)
  //   goldLight -> Paprika   (subtle variant)
  //   goldDark  -> PaprikaDeep
  //   goldWarm  -> White     (used for hero ribbons over dark photos)
  static const light = AppColors(
    paprika: Color(0xFF93003C),
    paprikaLight: Color(0xFFB8145E),
    paprikaDark: Color(0xFF6E002D),
    paprikaDeep: Color(0xFF5A0026),
    thunder: Color(0xFF252122),
    thunderLight: Color(0xFF3A3536),
    salem: Color(0xFF0F8044),
    salemLight: Color(0xFF14A358),
    gold: Color(0xFF93003C),
    goldLight: Color(0xFFB8145E),
    goldDark: Color(0xFF5A0026),
    goldWarm: Color(0xFFFFFFFF),
    charcoal: Color(0xFFFAF6EE),
    surface1: Color(0x0A000000),
    surface2: Color(0x0F000000),
    surface3: Color(0x14000000),
    surface4: Color(0x1F000000),
    textPrimary: Color(0xDE000000),
    textSecondary: Color(0x99000000),
    textTertiary: Color(0x61000000),
    borderSubtle: Color(0x0F000000),
    borderDefault: Color(0x1A000000),
    borderStrong: Color(0x29000000),
    success: Color(0xFF0F8044),
    warning: Color(0xFFD4960A),
    error: Color(0xFFC4342A),
    info: Color(0xFF3B6FD4),
    charcoalDeep: Color(0xFFF2EDED),
    navBarBackground: Color(0xF5FFFFFF),
    inkOnHero: Color(0xFFFFFFFF),
    scrim: Color(0x80000000),
  );

  static const dark = AppColors(
    paprika: Color(0xFF93003C),
    paprikaLight: Color(0xFFB8145E),
    paprikaDark: Color(0xFF6E002D),
    paprikaDeep: Color(0xFF3A0019),
    thunder: Color(0xFF252122),
    thunderLight: Color(0xFF3A3536),
    salem: Color(0xFF0F8044),
    salemLight: Color(0xFF14A358),
    gold: Color(0xFFFFFFFF),
    goldLight: Color(0xFFFFFFFF),
    goldDark: Color(0xFFFFFFFF),
    goldWarm: Color(0xFFFFFFFF),
    charcoal: Color(0xFF1C1819),
    surface1: Color(0x0AFFFFFF),
    surface2: Color(0x12FFFFFF),
    surface3: Color(0x1AFFFFFF),
    surface4: Color(0x24FFFFFF),
    textPrimary: Color(0xDEFFFFFF),
    textSecondary: Color(0x99FFFFFF),
    textTertiary: Color(0x61FFFFFF),
    borderSubtle: Color(0x0FFFFFFF),
    borderDefault: Color(0x1AFFFFFF),
    borderStrong: Color(0x29FFFFFF),
    success: Color(0xFF14A358),
    warning: Color(0xFFE8A838),
    error: Color(0xFFD4544A),
    info: Color(0xFF5B8DEF),
    charcoalDeep: Color(0xFF14101C),
    navBarBackground: Color(0xEB1C1819),
    inkOnHero: Color(0xFFFFFFFF),
    scrim: Color(0xA0000000),
  );

  @override
  AppColors copyWith({
    Color? paprika,
    Color? paprikaLight,
    Color? paprikaDark,
    Color? paprikaDeep,
    Color? thunder,
    Color? thunderLight,
    Color? salem,
    Color? salemLight,
    Color? gold,
    Color? goldLight,
    Color? goldDark,
    Color? goldWarm,
    Color? charcoal,
    Color? surface1,
    Color? surface2,
    Color? surface3,
    Color? surface4,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? charcoalDeep,
    Color? navBarBackground,
    Color? inkOnHero,
    Color? scrim,
  }) {
    return AppColors(
      paprika: paprika ?? this.paprika,
      paprikaLight: paprikaLight ?? this.paprikaLight,
      paprikaDark: paprikaDark ?? this.paprikaDark,
      paprikaDeep: paprikaDeep ?? this.paprikaDeep,
      thunder: thunder ?? this.thunder,
      thunderLight: thunderLight ?? this.thunderLight,
      salem: salem ?? this.salem,
      salemLight: salemLight ?? this.salemLight,
      gold: gold ?? this.gold,
      goldLight: goldLight ?? this.goldLight,
      goldDark: goldDark ?? this.goldDark,
      goldWarm: goldWarm ?? this.goldWarm,
      charcoal: charcoal ?? this.charcoal,
      surface1: surface1 ?? this.surface1,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      surface4: surface4 ?? this.surface4,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      charcoalDeep: charcoalDeep ?? this.charcoalDeep,
      navBarBackground: navBarBackground ?? this.navBarBackground,
      inkOnHero: inkOnHero ?? this.inkOnHero,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      paprika: Color.lerp(paprika, other.paprika, t)!,
      paprikaLight: Color.lerp(paprikaLight, other.paprikaLight, t)!,
      paprikaDark: Color.lerp(paprikaDark, other.paprikaDark, t)!,
      paprikaDeep: Color.lerp(paprikaDeep, other.paprikaDeep, t)!,
      thunder: Color.lerp(thunder, other.thunder, t)!,
      thunderLight: Color.lerp(thunderLight, other.thunderLight, t)!,
      salem: Color.lerp(salem, other.salem, t)!,
      salemLight: Color.lerp(salemLight, other.salemLight, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldLight: Color.lerp(goldLight, other.goldLight, t)!,
      goldDark: Color.lerp(goldDark, other.goldDark, t)!,
      goldWarm: Color.lerp(goldWarm, other.goldWarm, t)!,
      charcoal: Color.lerp(charcoal, other.charcoal, t)!,
      surface1: Color.lerp(surface1, other.surface1, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      surface4: Color.lerp(surface4, other.surface4, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      charcoalDeep: Color.lerp(charcoalDeep, other.charcoalDeep, t)!,
      navBarBackground:
          Color.lerp(navBarBackground, other.navBarBackground, t)!,
      inkOnHero: Color.lerp(inkOnHero, other.inkOnHero, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}

extension AppColorsExtension on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.dark;
}
