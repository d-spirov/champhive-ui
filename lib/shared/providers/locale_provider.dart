import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App UI locales. `null` follows the device language when supported.
final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

class AppLocales {
  AppLocales._();

  static const english = Locale('en');
  static const macedonian = Locale('mk');
  static const serbian = Locale.fromSubtags(
    languageCode: 'sr',
    scriptCode: 'Latn',
  );
  static const italian = Locale('it');

  static const supported = <Locale>[
    english,
    macedonian,
    serbian,
    italian,
  ];

  /// API / account locale tags used by ClubPlatform (`sr-Latn`, etc.).
  static String toApiTag(Locale locale) {
    if (locale.languageCode == 'sr') return 'sr-Latn';
    return locale.languageCode;
  }

  static Locale? tryParse(String? raw) {
    if (raw == null || raw.isEmpty || raw == 'system') return null;
    final normalized = raw.replaceAll('_', '-');
    if (normalized == 'en') return english;
    if (normalized == 'mk') return macedonian;
    if (normalized == 'it') return italian;
    if (normalized == 'sr' ||
        normalized.toLowerCase() == 'sr-latn' ||
        normalized == 'sr_Latn') {
      return serbian;
    }
    return null;
  }

  static String storageKey(Locale? locale) {
    if (locale == null) return 'system';
    if (locale.languageCode == 'sr') return 'sr-Latn';
    return locale.languageCode;
  }
}

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _load();
  }

  static const _key = 'app_locale';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppLocales.tryParse(prefs.getString(_key));
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, AppLocales.storageKey(locale));
  }
}
