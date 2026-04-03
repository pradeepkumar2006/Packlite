import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/ai_service.dart';

class Message {
  final String text;
  final bool isUser;
  Message(this.text, this.isUser);
}

class AIConciergeSheet extends StatefulWidget {
  const AIConciergeSheet({super.key});

  @override
  State<AIConciergeSheet> createState() => _AIConciergeSheetState();
}

class _AIConciergeSheetState extends State<AIConciergeSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [
    Message("Hello! I'm your PackLite AI Concierge. How can I help you with your journey today?", false),
  ];
  bool _isTyping = false;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    final userText = _controller.text;
    setState(() {
      _messages.add(Message(userText, true));
      _controller.clear();
      _isTyping = true;
    });

    PackLiteTheme.haptic();

    try {
      final aiRes = await AIService.chat(userText);
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(Message(aiRes, false));
        });
        PackLiteTheme.haptic();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(Message("I'm momentarily offline. Let's try again in a bit!", false));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.blueAccent, size: 24),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI CONCIERGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2)),
                    Text('Always Online • Smart Assistant', style: TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, size: 20)),
              ],
            ),
          ),
          const Divider(height: 32),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                return Align(
                  alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: m.isUser ? Colors.black : const Color(0xFFF1F1ED),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(24),
                        topRight: const Radius.circular(24),
                        bottomLeft: Radius.circular(m.isUser ? 24 : 4),
                        bottomRight: Radius.circular(m.isUser ? 4 : 24),
                      ),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        color: m.isUser ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('AI is thinking...', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: PackLiteTheme.cardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: PackLiteTheme.background,
                borderRadius: BorderRadius.circular(100),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Ask anything about your trip...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Tappable(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
