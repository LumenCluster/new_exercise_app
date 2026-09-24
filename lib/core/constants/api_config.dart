/// Gemini key for local dev. Override at build time with:
///   flutter run --dart-define=GEMINI_API_KEY=<key>
/// Get one at https://aistudio.google.com/apikey
class ApiConfig {
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const String geminiModel = 'gemini-3.6-flash';
  static const String imageModel = 'gemini-2.5-flash-image';

  static const String geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';

  static const String imageEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$imageModel:generateContent';

  /// Headers for every Gemini request. Throws a readable error up front
  /// instead of letting the API answer with a bare 401.
  static Map<String, String> get geminiHeaders {
    if (geminiApiKey.isEmpty) {
      throw StateError(
        'GEMINI_API_KEY is not set. Run with --dart-define=GEMINI_API_KEY=<your key>.',
      );
    }
    return {
      'Content-Type': 'application/json',
      'x-goog-api-key': geminiApiKey,
    };
  }
}
