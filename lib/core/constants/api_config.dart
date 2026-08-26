/// Store your API key here for local dev only.
class ApiConfig {
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AQ.Ab8RN6LkgNeI0iVcP4Q8ppp-Zs4ex_tzA86gup5ti3y8Qx369Q',
  );

  static const String geminiModel = 'gemini-3.6-flash';
  static const String imageModel = 'gemini-2.5-flash-image';

  static String get geminiEndpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey';

  static String get imageEndpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$imageModel:generateContent?key=$geminiApiKey';
}
