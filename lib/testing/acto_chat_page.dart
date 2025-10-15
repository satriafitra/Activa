import 'package:flutter/material.dart';
import 'package:active/services/acto_voice_service.dart';

class ActoChatPage extends StatefulWidget {
  const ActoChatPage({super.key});

  @override
  State<ActoChatPage> createState() => _ActoChatPageState();
}

class _ActoChatPageState extends State<ActoChatPage> {
  final ActoVoiceService _voice = ActoVoiceService();
  final List<Map<String, String>> _chats = [];
  bool _isProcessing = false;

  void _startVoiceChat() async {
    setState(() => _isProcessing = true);

    // Tambahkan placeholder "Acto sedang berpikir..."
    setState(() {
      _chats.add({'role': 'acto', 'text': '💭 Acto sedang berpikir...'});
    });

    try {
      await _voice.processVoice((user, acto) {
        // Hapus placeholder jika ada
        _chats.removeWhere((c) => c['text'] == '💭 Acto sedang berpikir...');
        setState(() {
          _chats.add({'role': 'user', 'text': user});
          _chats.add({'role': 'acto', 'text': acto});
        });
      });
    } catch (e) {
      debugPrint('❌ Voice chat error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E16),
      appBar: AppBar(
        title: const Text(
          'Acto Voice Mode',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                final isUser = chat['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.orange
                          : Colors.grey[800]?.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      chat['text']!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _isProcessing ? null : _startVoiceChat,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isProcessing ? Colors.grey : Colors.orange,
                boxShadow: _isProcessing
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ],
              ),
              width: 72,
              height: 72,
              child: Icon(
                _isProcessing ? Icons.hearing_disabled : Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
