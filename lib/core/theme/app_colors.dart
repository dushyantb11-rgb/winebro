import 'package:flutter/material.dart';

/// WineBro color tokens. Brand-locked: paprika #93003C, salem #0F8044,
/// thunder #252122. Everything else is supporting cast.
///
/// Token tiers:
///   Brand        paprika / paprikaLight / paprikaDark / paprikaDeep
///                salem / salemLight / thunder / thunderLight
///   On-dark text paprikaOnDark / salemOnDark (AA on dark surfaces)
///   Emphasis     highlight / onPrimary
///   Backgrounds  background / backgroundDeep / surface1..4 (lift levels)
///   Text         textPrimary / textSecondary / textTertiary
///   Borders      borderSubtle / borderDefault / borderStrong
///   Status       success / warning / error / info
///   Cinematic    inkOnHero (always white) / scrim (photo overlay)
///   Chrome       navBarBackground
///   Camera       cameraCanvas / cameraGlow / cameraGhost
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
    required this.salemOnDark,
    required this.paprikaOnDark,
    required this.highlight,
    required this.onPrimary,
    required this.background,
    required this.backgroundDeep,
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
    required this.navBarBackground,
    required this.inkOnHero,
    required this.scrim,
    required this.cameraCanvas,
    required this.cameraGlow,
    required this.cameraGhost,
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
  /// Fill only. White text on it is 3.3:1, below AA.
  final Color salemLight;

  /// Salem brightened for text on dark surfaces: #1FBA68 on
  /// background #1C1819 = 6.9:1. Aliased to brand salem in the light
  /// theme so consumers can route unconditionally.
  final Color salemOnDark;

  /// Paprika brightened for text on dark surfaces: #E0668A on
  /// background #1C1819 = 5.4:1 (brand paprika is only 1.9:1 there).
  /// Aliased to brand paprika in the light theme.
  final Color paprikaOnDark;

  /// Emphasis colour for values, active marks and ribbons on body
  /// surfaces. The CHV brand guide has no gold: highlights are Paprika on
  /// light backgrounds and White on dark ones.
  final Color highlight;

  /// Text and icons on paprika / salem fills (9.1:1 on paprika).
  final Color onPrimary;

  /// Page background.
  final Color background;

  /// Bottom stop of page gradients. Warm, same hue family as Thunder.
  final Color backgroundDeep;

  final Color surface1;
  final Color surface2;
  final Color surface3;
  final Color surface4;
  final Color textPrimary;
  final Color textSecondary;
  /// Captions, labels and hints. 4.5:1 light, 5.3:1 dark (AA).
  final Color textTertiary;

  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  final Color success;
  /// Fills and icons. As text on the light background it is 2.4:1,
  /// so do not use it for text in the light theme.
  final Color warning;

  final Color error;
  final Color info;
  final Color navBarBackground;
  /// Always white. Use for text and marks on cinematic dark photography
  /// and on the always-dark camera screen, regardless of active theme.
  final Color inkOnHero;

  /// Photo scrim. Stronger in dark to keep text readable against
  /// brighter mid-tones in photography.
  final Color scrim;

  /// Scanner screen, always dark: canvas, centre glow, ghost icon.
  final Color cameraCanvas;

  final Color cameraGlow;
  final Color cameraGhost;

  static const light = AppColors(
    paprika: Color(0xFF93003C),
    paprikaLight: Color(0xFFB8145E),
    paprikaDark: Color(0xFF6E002D),
    paprikaDeep: Color(0xFF5A0026),
    thunder: Color(0xFF252122),
    thunderLight: Color(0xFF3A3536),
    salem: Color(0xFF0F8044),
    salemLight: Color(0xFF14A358),
    salemOnDark: Color(0xFF0F8044),
    paprikaOnDark: Color(0xFF93003C),
    highlight: Color(0xFF93003C),
    onPrimary: Color(0xFFFFFFFF),
    background: Color(0xFFFAF6EE),
    backgroundDeep: Color(0xFFF2EDED),
    surface1: Color(0x0A000000),
    surface2: Color(0x0F000000),
    surface3: Color(0x14000000),
    surface4: Color(0x1F000000),
    textPrimary: Color(0xDE000000),
    textSecondary: Color(0x99000000),
    textTertiary: Color(0x8A000000),
    borderSubtle: Color(0x0F000000),
    borderDefault: Color(0x1A000000),
    borderStrong: Color(0x29000000),
    success: Color(0xFF0F8044),
    warning: Color(0xFFD4960A),
    error: Color(0xFFC4342A),
    info: Color(0xFF3462C4),
    navBarBackground: Color(0xF5FFFFFF),
    inkOnHero: Color(0xFFFFFFFF),
    scrim: Color(0x80000000),
    cameraCanvas: Color(0xFF050505),
    cameraGlow: Color(0xFF1A0408),
    cameraGhost: Color(0xFF1F1A1B),
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
    salemOnDark: Color(0xFF1FBA68),
    paprikaOnDark: Color(0xFFE0668A),
    highlight: Color(0xFFFFFFFF),
    onPrimary: Color(0xFFFFFFFF),
    background: Color(0xFF1C1819),
    backgroundDeep: Color(0xFF141011),
    surface1: Color(0x0AFFFFFF),
    surface2: Color(0x12FFFFFF),
    surface3: Color(0x1AFFFFFF),
    surface4: Color(0x24FFFFFF),
    textPrimary: Color(0xDEFFFFFF),
    textSecondary: Color(0x99FFFFFF),
    textTertiary: Color(0x80FFFFFF),
    borderSubtle: Color(0x0FFFFFFF),
    borderDefault: Color(0x1AFFFFFF),
    borderStrong: Color(0x29FFFFFF),
    success: Color(0xFF14A358),
    warning: Color(0xFFE8A838),
    error: Color(0xFFE06A60),
    info: Color(0xFF5B8DEF),
    navBarBackground: Color(0xEB1C1819),
    inkOnHero: Color(0xFFFFFFFF),
    scrim: Color(0xA0000000),
    cameraCanvas: Color(0xFF050505),
    cameraGlow: Color(0xFF1A0408),
    cameraGhost: Color(0xFF1F1A1B),
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
    Color? salemOnDark,
    Color? paprikaOnDark,
    Color? highlight,
    Color? onPrimary,
    Color? background,
    Color? backgroundDeep,
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
    Color? navBarBackground,
    Color? inkOnHero,
    Color? scrim,
    Color? cameraCanvas,
    Color? cameraGlow,
    Color? cameraGhost,
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
      salemOnDark: salemOnDark ?? this.salemOnDark,
      paprikaOnDark: paprikaOnDark ?? this.paprikaOnDark,
      highlight: highlight ?? this.highlight,
      onPrimary: onPrimary ?? this.onPrimary,
      background: background ?? this.background,
      backgroundDeep: backgroundDeep ?? this.backgroundDeep,
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
      navBarBackground: navBarBackground ?? this.navBarBackground,
      inkOnHero: inkOnHero ?? this.inkOnHero,
      scrim: scrim ?? this.scrim,
      cameraCanvas: cameraCanvas ?? this.cameraCanvas,
      cameraGlow: cameraGlow ?? this.cameraGlow,
      cameraGhost: cameraGhost ?? this.cameraGhost,
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
      salemOnDark: Color.lerp(salemOnDark, other.salemOnDark, t)!,
      paprikaOnDark: Color.lerp(paprikaOnDark, other.paprikaOnDark, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundDeep: Color.lerp(backgroundDeep, other.backgroundDeep, t)!,
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
      navBarBackground: Color.lerp(navBarBackground, other.navBarBackground, t)!,
      inkOnHero: Color.lerp(inkOnHero, other.inkOnHero, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      cameraCanvas: Color.lerp(cameraCanvas, other.cameraCanvas, t)!,
      cameraGlow: Color.lerp(cameraGlow, other.cameraGlow, t)!,
      cameraGhost: Color.lerp(cameraGhost, other.cameraGhost, t)!,
    );
  }
}

extension AppColorsExtension on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.dark;

  /// Salem variant suitable for TEXT/ICON on the active theme's body
  /// surfaces (background + surface1/2/3/4). Routes through `salemOnDark`
  /// in dark theme to clear AA (6.9:1 vs 3.5:1).
  ///
  /// **Do NOT use on hero gradients** (paprika-coloured backgrounds) —
  /// plain `salem` already has enough contrast against paprika.
  Color get salemOnSurface {
    final colors = appColors;
    return Theme.of(this).brightness == Brightness.dark
        ? colors.salemOnDark
        : colors.salem;
  }

  /// Paprika variant suitable for TEXT/ICON on the active theme's body
  /// surfaces. Routes through `paprikaOnDark` in dark theme (5.4:1).
  ///
  /// **Do NOT use on inkOnHero contexts** — white is the rule there.
  Color get paprikaOnSurface {
    final colors = appColors;
    return Theme.of(this).brightness == Brightness.dark
        ? colors.paprikaOnDark
        : colors.paprika;
  }
}
