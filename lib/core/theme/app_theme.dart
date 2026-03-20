import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';


class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const colors = AppColors.light;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.charcoal,
      colorScheme: ColorScheme.light(
        primary: colors.paprika,
        secondary: colors.salem,
        tertiary: colors.gold,
        surface: colors.charcoal,
        error: colors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: colors.textPrimary,
        onError: Colors.white,
      ),
      fontFamily: 'Montserrat',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: -1),
        displayMedium: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 26, fontWeight: FontWeight.w700),
        displaySmall: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 22, fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.charcoal,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.navBarBackground,
        selectedItemColor: colors.paprika,
        unselectedItemColor: colors.textTertiary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.borderDefault),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.paprika,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.paprika,
          side: BorderSide(color: colors.paprika),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.borderDefault)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.borderDefault)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.paprika, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.error)),
        hintStyle: TextStyle(color: colors.textTertiary, fontSize: 14),
        labelStyle: TextStyle(color: colors.textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: colors.paprika.withValues(alpha: 0.1),
        side: BorderSide(color: colors.borderDefault),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: TextStyle(color: colors.textSecondary, fontSize: 12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.paprika,
        linearTrackColor: colors.surface2,
      ),
      dividerTheme: DividerThemeData(color: colors.borderSubtle, thickness: 1),
      extensions: const [AppColors.light],
    );
  }

  static ThemeData get dark {
    const colors = AppColors.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.charcoal,
      colorScheme: ColorScheme.dark(
        primary: colors.paprika,
        secondary: colors.salem,
        tertiary: colors.gold,
        surface: colors.charcoal,
        error: colors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: colors.textPrimary,
        onError: Colors.white,
      ),
      fontFamily: 'Montserrat',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 52,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 26,
          fontWeight: FontWeight.w700,
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
        titleLarge: TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 22,
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
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w400,
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
        labelSmall: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.charcoal,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.navBarBackground,
        selectedItemColor: colors.paprikaLight,
        unselectedItemColor: colors.textTertiary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.borderDefault),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.paprika,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.paprikaLight,
          side: BorderSide(color: colors.paprika),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.paprika, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.error),
        ),
        hintStyle: TextStyle(color: colors.textTertiary, fontSize: 14),
        labelStyle: TextStyle(color: colors.textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: colors.paprika.withValues(alpha: 0.15),
        side: BorderSide(color: colors.borderDefault),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: TextStyle(
          color: colors.textSecondary,
          fontSize: 12,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.paprika,
        linearTrackColor: colors.surface2,
      ),
      dividerTheme: DividerThemeData(
        color: colors.borderSubtle,
        thickness: 1,
      ),
      extensions: const [AppColors.dark],
    );
  }
}
