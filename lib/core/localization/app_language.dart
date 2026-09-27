class AppLanguage {
  final String code;
  final String englishName;
  final String nativeName;

  const AppLanguage(this.code, this.englishName, this.nativeName);
}

const List<AppLanguage> kSupportedLanguages = [
  AppLanguage('en', 'English', 'English'),
  AppLanguage('es', 'Spanish', 'Español'),
  AppLanguage('fr', 'French', 'Français'),
  AppLanguage('de', 'German', 'Deutsch'),
  AppLanguage('hi', 'Hindi', 'हिन्दी'),
];

AppLanguage languageForCode(String code) => kSupportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => kSupportedLanguages.first,
    );
