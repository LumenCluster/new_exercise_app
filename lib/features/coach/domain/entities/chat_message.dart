enum ChatRole { user, model }

class ChatMessage {
  final ChatRole role;
  final String text;
  final DateTime? sentAt;

  const ChatMessage({required this.role, required this.text, this.sentAt});
}
