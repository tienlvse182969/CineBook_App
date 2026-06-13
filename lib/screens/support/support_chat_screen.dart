import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/data/mock_support.dart';

// ── Message model ────────────────────────────────────────────────

class _Msg {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isTyping;

  _Msg({
    required this.text,
    required this.isUser,
    DateTime? time,
    this.isTyping = false,
  }) : time = time ?? DateTime.now();
}

// ── Screen ───────────────────────────────────────────────────────

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _isSending = false;
  bool _hasUserMessage = false;

  final List<_Msg> _messages = [
    _Msg(
      text: 'Xin chào! 👋 Tôi là trợ lý hỗ trợ của CineBook.',
      isUser: false,
      time: DateTime.now(),
    ),
    _Msg(
      text: 'Tôi có thể giúp bạn về đặt vé, thanh toán, điểm thưởng hoặc thông tin phim. Bạn cần hỗ trợ gì?',
      isUser: false,
      time: DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Send logic — thay phần này bằng AI API call sau ────────────
  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    setState(() {
      _messages.add(_Msg(text: text.trim(), isUser: true));
      _hasUserMessage = true;
      _isSending = true;
    });
    _ctrl.clear();
    _scrollToBottom();

    // Typing indicator
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _messages.add(_Msg(text: '', isUser: false, isTyping: true)));
    _scrollToBottom();

    // TODO: thay đoạn này bằng: final reply = await AiService.chat(text);
    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() {
      _messages.removeLast(); // xóa typing indicator
      _messages.add(_Msg(text: supportAutoReply(text), isUser: false));
      _isSending = false;
    });
    _scrollToBottom();
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Stack(
        children: [
          _buildBg(),
          Column(
            children: [
              SafeArea(bottom: false, child: _buildHeader(context)),
              Expanded(child: _buildMessageList()),
              _buildInputBar(context),
            ],
          ),
        ],
      ),
    );
  }

  // ── Background ───────────────────────────────────────────────

  Widget _buildBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0E1A), Color(0xFF0C1530), Color(0xFF080C14)],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          ),
          child: Row(
            children: [
              // Back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Agent avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE50914), Color(0xFF8B0000)],
                      ),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.bot, color: Colors.white, size: 20),
                    ),
                  ),
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4CAF50),
                      border: Border.all(color: const Color(0xFF080C14), width: 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              // Name + status
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trợ lý CineBook', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(LucideIcons.circle, size: 7, color: Color(0xFF4CAF50)),
                        SizedBox(width: 4),
                        Text('Đang hoạt động', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),

              // Info button
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Icon(LucideIcons.info, size: 16, color: Colors.white.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Message list ─────────────────────────────────────────────

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length + (_hasUserMessage ? 0 : 1), // +1 for quick replies
      itemBuilder: (context, i) {
        if (!_hasUserMessage && i == _messages.length) {
          return _buildQuickReplies();
        }
        final msg = _messages[i];
        return msg.isTyping
            ? _buildTypingBubble()
            : _buildBubble(msg);
      },
    );
  }

  Widget _buildBubble(_Msg msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFFE50914), Color(0xFF8B0000)]),
              ),
              child: const Icon(LucideIcons.bot, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFFE50914).withValues(alpha: 0.85)
                            : Colors.white.withValues(alpha: 0.09),
                        border: isUser
                            ? null
                            : Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.white.withValues(alpha: 0.88),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 10),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFE50914), Color(0xFF8B0000)]),
            ),
            child: const Icon(LucideIcons.bot, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4), bottomRight: Radius.circular(16),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.09),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: _TypingDots(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Câu hỏi thường gặp:', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: supportQuickReplies.map((q) => GestureDetector(
              onTap: () => _send(q),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE50914).withValues(alpha: 0.3)),
                    ),
                    child: Text(q, style: const TextStyle(color: Color(0xFFE50914), fontSize: 12)),
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ── Input bar ────────────────────────────────────────────────

  Widget _buildInputBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          ),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: TextField(
                      controller: _ctrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.28), fontSize: 14),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.07),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _send(_ctrl.text),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44, height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE50914), Color(0xFFB00000)],
                    ),
                    boxShadow: [BoxShadow(color: Color(0x33E50914), blurRadius: 12, offset: Offset(0, 4))],
                  ),
                  child: const Icon(LucideIcons.sendHorizontal, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Typing animation ─────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final offset = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
            final scale = 0.6 + 0.4 * (offset < 0.5 ? offset * 2 : (1 - offset) * 2);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.5 + 0.4 * scale),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
