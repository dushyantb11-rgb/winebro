import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';

const kSupportedLocales = [
  Locale('en'),
  Locale('hi'),
  Locale('mr'),
  Locale('gu'),
];

const kLocaleNames = {
  'en': 'English',
  'hi': 'हिंदी',
  'mr': 'मराठी',
  'gu': 'ગુજરાતી',
};

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale?>((ref) => LocaleNotifier());

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_kLocaleKey);
      if (code != null) state = Locale(code);
    } on Exception catch (_) {

    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }
}

