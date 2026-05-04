import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// WineBro theme.
///
/// Type rule:
///   Playfair Display = emotion (headlines, product names, quotes)
///   Montserrat       = function (UI, buttons, nav, chips, captions)
///
/// One hero per screen: `displayHero` (64sp Playfair 900) is reserved for
/// a single moment per route. `displayLarge` is the second-tier opener.
class AppTheme {
  AppTheme._();

  // ============= Text styles (shared across light + dark) =============

  static const TextTheme _textTheme = TextTheme(
    // Hero — one per screen MAX. Tonight's Pour, BroCard score, splash.
    displayLarge: TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: 44,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.5,
      height: 1.05,
    ),
    displayMedium: TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    // Product name in hero cards
    titleLarge: TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    // Eyebrow / category labels — uppercase, spaced
    labelSmall: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.8,
    ),
  );

  // ============= Light =============

  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: colors.paprika,
            secondary: colors.salem,
            tertiary: colors.gold,
            surface: colors.charcoal,
            error: colors.error,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: colors.textPrimary,
            onError: Colors.white,
          )
        : ColorScheme.light(
            primary: colors.paprika,
            secondary: colors.salem,
            tertiary: colors.gold,
            surface: colors.charcoal,
            error: colors.error,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: colors.textPrimary,
            onError: Colors.white,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.charcoal,
      colorScheme: colorScheme,
      fontFamily: 'Montserrat',
      textTheme: _textTheme.apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.charcoal,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.navBarBackground,
        selectedItemColor: isDark ? colors.paprikaLight : colors.paprika,
        unselectedItemColor: colors.textTertiary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: isDark ? colors.surface1 : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.borderSubtle),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.paprika,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? colors.paprikaLight : colors.paprika,
          side: BorderSide(color: colors.paprika, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? colors.paprikaLight : colors.paprika,
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.paprika, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.error),
        ),
        hintStyle: TextStyle(color: colors.textTertiary, fontSize: 14),
        labelStyle: TextStyle(color: colors.textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface1,
        selectedColor: colors.paprika.withValues(alpha: 0.15),
        side: BorderSide(color: colors.borderDefault),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: TextStyle(
          color: colors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.paprika,
        linearTrackColor: colors.surface2,
      ),
      dividerTheme: DividerThemeData(
        color: colors.borderSubtle,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.charcoal,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: colors.borderStrong,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.paprika,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: const CircleBorder(),
      ),
      extensions: [colors],
    );
  }
}

/// Convenient access to the WineBro semantic text styles.
///
/// Use these instead of inline TextStyle when the meaning matches:
///
///   Text('Tonight\'s Pour', style: context.serifQuote)
///   Text('Cellar Master', style: context.eyebrow)
extension AppTextStyles on BuildContext {
  /// Hero headline. 64sp Playfair 900. Reserve for ONE per screen.
  TextStyle get displayHero => const TextStyle(
        fontFamily: 'PlayfairDisplay',
        fontSize: 64,
        fontWeight: FontWeight.w900,
        letterSpacing: -2,
        height: 0.95,
      );

  /// Italic serif pull-quote. Use for tasting notes, Bro Tips, hero callouts.
  TextStyle get serifQuote => const TextStyle(
        fontFamily: 'PlayfairDisplay',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 1.4,
      );

  /// Tiny uppercase eyebrow label. "BRO'S PICK", "TRENDING NOW".
  TextStyle get eyebrow => const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      );

  /// BroCard score (9.2). Big Playfair 900.
  TextStyle get scoreNumber => const TextStyle(
        fontFamily: 'PlayfairDisplay',
        fontSize: 56,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: -2,
      );
}
