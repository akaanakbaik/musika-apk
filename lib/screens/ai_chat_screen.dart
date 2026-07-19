import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../config/theme.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final AiService _aiService = AiService();
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _loading = false;

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _loading = true;
    });
    _msgCtrl.clear();
    _scrollDown();

    try {
      final res = await _aiService.chat(text);
      final response = res['response'] ?? res['message'] ?? res['data'] ?? 'No response';
      setState(() {
        _messages.add(ChatMessage(role: 'assistant', content: response.toString()));
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(role: 'assistant', content: 'Error: ${e.toString()}'));
        _loading = false;
      });
    }
    _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.primary, size: 20),
            SizedBox(width: 8),
            Text('AI Chat'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, size: 48, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text('Ask me anything about music!', style: TextStyle(color: Colors.grey[400])),
                        const SizedBox(height: 8),
                        Text('Find songs, artists, or get recommendations',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final isUser = msg.role == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isUser ? AppTheme.primary.withValues(alpha: 0.2) : const Color(0xFF282828),
                            borderRadius: isUser
                                ? const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(4), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))
                                : const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                          ),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                          child: Text(msg.content, style: TextStyle(color: isUser ? Colors.white : Colors.grey[300])),
                        ),
                      );
                    },
                  ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Ask about music...',
                      border: InputBorder.none,
                      filled: false,
                    ),
                    onSubmitted: _send,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppTheme.primary),
                  onPressed: () => _send(_msgCtrl.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String role;
  final String content;
  ChatMessage({required this.role, required this.content});
}
