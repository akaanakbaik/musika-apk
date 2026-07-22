import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_service.dart';
import '../config/theme.dart';
import '../widgets/markdown_text.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final AiService _aiService = AiService();
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;
  bool _isAiTyping = false;

  @override
  void initState() {
    super.initState();
    final welcome = _ChatMessage(
      text: 'Halo! Saya **Musika AI**, asisten musik pribadimu.\n\nTanya apa aja tentang musik, rekomendasi lagu, atau cara pakai fitur Musika!',
      isUser: false,
      timestamp: DateTime.now(),
      isTyping: false,
    );
    _messages.add(welcome);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
        isTyping: false,
      ));
      _loading = true;
    });
    _inputCtrl.clear();
    _scrollToBottom();

    try {
      final res = await _aiService.chat(text);
      final reply = res['reply']?.toString() ??
          res['message']?.toString() ??
          'Maaf, aku tidak bisa menjawab saat ini. Coba lagi ya!';
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: reply,
            isUser: false,
            timestamp: DateTime.now(),
            isTyping: true,
          ));
          _loading = false;
          _isAiTyping = true;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: 'Maaf, terjadi kesalahan. Coba lagi nanti ya!',
            isUser: false,
            timestamp: DateTime.now(),
            isTyping: true,
          ));
          _loading = false;
          _isAiTyping = true;
        });
      }
    }
  }

  void _onTypingComplete(int index) {
    if (!mounted) return;
    setState(() {
      if (index < _messages.length) {
        _messages[index] = _ChatMessage(
          text: _messages[index].text,
          isUser: _messages[index].isUser,
          timestamp: _messages[index].timestamp,
          isTyping: false,
        );
      }
      _isAiTyping = false;
    });
    _scrollToBottom();
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add(_ChatMessage(
        text: 'Percakapan dibersihkan! Ada yang bisa aku bantu?',
        isUser: false,
        timestamp: DateTime.now(),
        isTyping: false,
      ));
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Musika AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Asisten musik', style: TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: 'Bersihkan chat',
            onPressed: _messages.length > 1 ? _clearChat : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_outlined, size: 48, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text('Mulai percakapan', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_loading && !_isAiTyping ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (_loading && !_isAiTyping && i == _messages.length) {
                        return _buildLoadingBubble(isDark);
                      }
                      return _buildMessageBubble(_messages[i], i, isDark);
                    },
                  ),
          ),
          _buildInputArea(isDark),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 12, right: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputCtrl,
              decoration: InputDecoration(
                hintText: 'Tanya tentang musik...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                filled: true,
                fillColor: isDark ? const Color(0xFF282828) : const Color(0xFFF0F0F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              maxLines: 4,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(Icons.send, color: Colors.black, size: 22),
              onPressed: _loading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg, int index, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!msg.isUser) ...[
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome, size: 14, color: Colors.black),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: msg.isUser
                        ? AppTheme.primary
                        : (isDark ? const Color(0xFF282828) : const Color(0xFFF0F0F0)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: msg.isUser ? const Radius.circular(18) : Radius.zero,
                      bottomRight: msg.isUser ? Radius.zero : const Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (msg.isUser)
                        Text(
                          msg.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: msg.isUser ? Colors.black : (isDark ? Colors.white : const Color(0xFF121212)),
                            height: 1.5,
                          ),
                        )
                      else if (msg.isTyping)
                        TypingText(
                          fullText: msg.text,
                          fontSize: 14,
                          color: isDark ? Colors.white : const Color(0xFF121212),
                          onComplete: () => _onTypingComplete(index),
                        )
                      else
                        MarkdownText(
                          text: msg.text,
                          fontSize: 14,
                          color: isDark ? Colors.white : null,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(msg.timestamp),
                            style: TextStyle(
                              fontSize: 10,
                              color: msg.isUser ? Colors.black54 : Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: msg.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pesan disalin'),
                                  duration: Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Icon(Icons.copy, size: 14, color: msg.isUser ? Colors.black38 : Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (msg.isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, size: 16, color: AppTheme.primary),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, size: 14, color: Colors.black),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF282828) : const Color(0xFFF0F0F0),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(isDark), const SizedBox(width: 4),
                _dot(isDark), const SizedBox(width: 4),
                _dot(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(bool isDark) => Container(
    width: 8, height: 8,
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[500] : Colors.grey[400],
      shape: BoxShape.circle,
    ),
  );

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;
  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.isTyping,
  });
}
