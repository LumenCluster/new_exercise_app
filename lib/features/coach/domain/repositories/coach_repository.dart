import '../entities/chat_message.dart';

abstract class CoachRepository {
  /// Sends the full conversation so far (system prompt sets the coach's
  /// persona) and returns the assistant's reply text.
  Future<String> sendMessage({
    required String systemPrompt,
    required List<ChatMessage> history,
  });
}
