import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/features/coach/domain/entities/chat_message.dart';
import 'package:untitled/features/coach/domain/repositories/coach_repository.dart';
import 'package:untitled/core/localization/app_localizations.dart';

class _ChatColors {
  static const background = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF1B2A26);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
}

/// Shared chat UI for both the Fitness Coach and the AI Nutrition Coach —
/// only the persona (title/systemPrompt/greeting) differs between the two.
class CoachChatScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String systemPrompt;
  final String greeting;

  const CoachChatScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.systemPrompt,
    required this.greeting,
  });

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(role: ChatRole.model, text: widget.greeting));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(ChatMessage(role: ChatRole.user, text: text));
      _inputController.clear();
      _sending = true;
      _error = null;
    });
    _scrollToBottom();

    try {
      final repository = context.read<CoachRepository>();
      final reply = await repository.sendMessage(
        systemPrompt: widget.systemPrompt,
        history: _messages,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(role: ChatRole.model, text: reply));
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = context.tr('coach_error_unreachable');
        _sending = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ChatColors.background,
      appBar: AppBar(
        backgroundColor: _ChatColors.background,
        elevation: 0,
        foregroundColor: _ChatColors.textPrimary,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: widget.accentColor.withValues(alpha: 0.15),
              child: Icon(widget.icon, size: 16, color: widget.accentColor),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(widget.subtitle, style: const TextStyle(fontSize: 10, color: _ChatColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_sending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _buildTypingBubble();
                  }
                  return _buildBubble(_messages[index]);
                },
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_error!, style: const TextStyle(fontSize: 11, color: Colors.redAccent)),
              ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(ChatMessage message) {
    final isUser = message.role == ChatRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? _ChatColors.primaryDark : _ChatColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 13,
            color: isUser ? Colors.white : _ChatColors.textPrimary,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _ChatColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: _ChatColors.primaryDark),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: _ChatColors.background,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _ChatColors.cardWhite,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: context.tr('coach_input_hint'),
                  hintStyle: const TextStyle(fontSize: 12, color: _ChatColors.textSecondary),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: _ChatColors.primaryDark,
              child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
