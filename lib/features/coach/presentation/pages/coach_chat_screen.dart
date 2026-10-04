import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/features/coach/domain/entities/chat_message.dart';
import 'package:untitled/features/coach/domain/repositories/coach_repository.dart';
import 'package:untitled/core/localization/app_localizations.dart';

class _ChatColors {
  static const background = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF1B2A26);
  static const userBubble = Color(0xFF1F3B2D);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
  static const activeGreen = Color(0xFF4CAF50);
  static const badgeBg = Color(0xFFE6F4E1);
  static const badgeText = Color(0xFF3E7D2B);
  static const border = Color(0xFFE6E6E0);
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
  final String avatarAsset;
  final List<String> suggestions;

  const CoachChatScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.systemPrompt,
    required this.greeting,
    this.avatarAsset = 'assets/ai.png',
    this.suggestions = const [],
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
    _messages.add(ChatMessage(role: ChatRole.model, text: widget.greeting, sentAt: DateTime.now()));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _inputController.text).trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(ChatMessage(role: ChatRole.user, text: text, sentAt: DateTime.now()));
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
        _messages.add(ChatMessage(role: ChatRole.model, text: reply, sentAt: DateTime.now()));
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

  String _formatTime(DateTime time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(time));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ChatColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
            if (widget.suggestions.isNotEmpty) _buildSuggestions(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _ChatColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: _ChatColors.textPrimary,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  widget.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _ChatColors.badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(color: _ChatColors.badgeText, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.tr('coach_badge'),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: _ChatColors.badgeText,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(color: _ChatColors.activeGreen, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(
                context.tr('coach_active_now'),
                style: const TextStyle(fontSize: 11, color: _ChatColors.activeGreen, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipOval(
      child: Image.asset(
        widget.avatarAsset,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => CircleAvatar(
          radius: 18,
          backgroundColor: widget.accentColor.withValues(alpha: 0.15),
          child: Icon(widget.icon, size: 18, color: widget.accentColor),
        ),
      ),
    );
  }

  Widget _buildBubble(ChatMessage message) {
    final isUser = message.role == ChatRole.user;
    final maxWidth = MediaQuery.of(context).size.width * 0.68;

    final bubble = Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: isUser ? _ChatColors.userBubble : _ChatColors.cardWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isUser ? 16 : 4),
          topRight: Radius.circular(isUser ? 4 : 16),
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        ),
        border: isUser ? null : Border.all(color: _ChatColors.border),
        boxShadow: isUser
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1,
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 13,
                color: isUser ? Colors.white : _ChatColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          if (message.sentAt != null) ...[
            const SizedBox(height: 6),
            Text(
              _formatTime(message.sentAt!),
              style: TextStyle(
                fontSize: 9,
                color: isUser ? Colors.white60 : _ChatColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isUser
            ? [bubble]
            : [_buildAvatar(), const SizedBox(width: 10), bubble],
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _ChatColors.cardWhite,
              border: Border.all(color: _ChatColors.border),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: _ChatColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: widget.suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final suggestion = widget.suggestions[index];
          return Material(
            color: _ChatColors.cardWhite,
            shape: const StadiumBorder(side: BorderSide(color: _ChatColors.border)),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: _sending ? null : () => _send(suggestion),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Center(
                  child: Text(
                    suggestion,
                    style: const TextStyle(fontSize: 12, color: _ChatColors.textPrimary, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _ChatColors.cardWhite,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _ChatColors.border),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: _ChatColors.badgeBg,
              child: Icon(Icons.add_rounded, color: _ChatColors.badgeText, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _inputController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: context.tr('coach_input_hint'),
                  hintStyle: const TextStyle(fontSize: 13, color: _ChatColors.textSecondary),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: _ChatColors.userBubble,
                child: Icon(Icons.send_rounded, color: Colors.white, size: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
