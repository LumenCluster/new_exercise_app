import 'package:flutter/material.dart';
import '../database/firestore_service.dart';
import 'app_language.dart';

const String _kLanguageCacheKey = 'settings_language_code';

/// Holds the app's active [Locale] and persists the user's choice so the
/// whole app (every screen using [AppLocalizations]) re-renders in the
/// selected language, and the choice survives app restarts.
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> load() async {
    final saved = await FirestoreService().getCacheValue(_kLanguageCacheKey);
    if (saved != null && kSupportedLanguages.any((l) => l.code == saved)) {
      _locale = Locale(saved);
      notifyListeners();
    }
  }

  Future<void> setLanguageCode(String code) async {
    if (_locale.languageCode == code) return;
    _locale = Locale(code);
    notifyListeners();
    await FirestoreService().setCacheValue(_kLanguageCacheKey, code);
  }
}
