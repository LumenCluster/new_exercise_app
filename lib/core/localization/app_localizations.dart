import 'package:flutter/material.dart';
import 'dictionaries/common_dict.dart';
import 'dictionaries/dashboard_dict.dart';
import 'dictionaries/profile_dict.dart';
import 'dictionaries/onboarding_dict.dart';
import 'dictionaries/onboarding_dict2.dart';
import 'dictionaries/exercises_dict.dart';
import 'dictionaries/meal_plan_dict.dart';
import 'dictionaries/report_dict.dart';
import 'dictionaries/coach_dict.dart';
import 'dictionaries/tracking_dict.dart';

/// Merges every feature's translation dictionary into one lookup table and
/// exposes `t(key)` to resolve a key against the active locale, falling
/// back to English and then the raw key if a translation is missing.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const List<Map<String, Map<String, String>>> _dictionaries = [
    commonDict,
    dashboardDict,
    profileDict,
    onboardingDict,
    onboardingDict2,
    exercisesDict,
    mealPlanDict,
    reportDict,
    coachDict,
    trackingDict,
  ];

  static final Map<String, Map<String, String>> _merged = {
    for (final dict in _dictionaries) ...dict,
  };

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Resolves [key] against the active locale (falling back to English,
  /// then the raw key). Pass [params] to fill `{placeholders}` in the
  /// translated string, e.g. t('glasses_count', {'count': '3', 'target': '8'}).
  String t(String key, [Map<String, String>? params]) {
    final entry = _merged[key];
    var value = entry == null ? key : (entry[locale.languageCode] ?? entry['en'] ?? key);
    params?.forEach((k, v) {
      value = value.replaceAll('{$k}', v);
    });
    return value;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

extension AppLocalizationsContext on BuildContext {
  String tr(String key, [Map<String, String>? params]) => AppLocalizations.of(this).t(key, params);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'fr', 'de', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
