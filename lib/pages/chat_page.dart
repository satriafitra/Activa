import 'package:active/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:active/components/sidebar.dart'; // pastikan import ini
import 'package:lottie/lottie.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<TextSpan> _parseFormattedText(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'(\*\*.*?\*\*|\*.*?\*|__.*?__)');

    int start = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }

      final matchText = match.group(0)!;

      if (matchText.startsWith('**')) {
        spans.add(TextSpan(
          text: matchText.substring(2, matchText.length - 2),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (matchText.startsWith('*')) {
        spans.add(TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else if (matchText.startsWith('__')) {
        spans.add(TextSpan(
          text: matchText.substring(2, matchText.length - 2),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      }

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  final _svc = GeminiService();
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_Msg>[];
  bool _isTyping = false;
  bool _isSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    _simulateTypingMessages();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  Future<void> _simulateTypingMessages() async {
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _messages.add(_Msg('Hai!', Role.bot));
    });
    await Future.delayed(const Duration(seconds: 1));
    _scrollJump();
    setState(() {
      _messages.add(_Msg('Ada yang bisa aku bantu? :D', Role.bot));
      _isTyping = false;
    });
    _scrollJump();
  }

  Future<void> _send() async {
    final prompt = _ctrl.text.trim();
    if (prompt.isEmpty || _isTyping) return;
    setState(() {
      _messages.add(_Msg(prompt, Role.user));
      _isTyping = true;
      _ctrl.clear();
    });

    _scrollJump();

    try {
      final reply = await _svc.sendPrompt(prompt);
      setState(() {
        _messages.add(_Msg(reply, Role.bot));
      });
    } catch (e) {
      setState(() {
        _messages.add(_Msg('⚠️ $e', Role.bot));
      });
    } finally {
      setState(() => _isTyping = false);
      _scrollJump();
    }
  }

  void _scrollJump() => Future.delayed(
        const Duration(milliseconds: 100),
        () => _scroll.jumpTo(_scroll.position.maxScrollExtent),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFeaf3fb), Color(0xFFfefefe)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleSidebar,
                            child: const Icon(Icons.menu,
                                color: Colors.black, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Acto",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (c, i) {
                          if (_isTyping && i == _messages.length) {
                            return _bubble('Acto is typing...', Role.bot,
                                isTyping: true);
                          }

                          final m = _messages[i];
                          final bool isHaiBubble =
                              m.role == Role.bot && m.text == 'Hai!';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isHaiBubble)
                                Center(
                                  child: Lottie.asset(
                                      'assets/animations/acto.json',
                                      repeat: true,
                                      fit: BoxFit.cover,
                                      height: 180,
                                      width: 180),
                                ),
                              _bubble(m.text, m.role),
                            ],
                          );
                        },
                      ),
                    ),
                    _inputBar(),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Sidebar Overlay
        SidebarOverlay(
          isOpen: _isSidebarOpen,
          onClose: _toggleSidebar,
          selectedItem: "Acto's Pal",
        ),
      ],
    );
  }

  Widget _bubble(String text, Role role, {bool isTyping = false}) {
    final isUser = role == Role.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF4e8cff) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isTyping
              ? Row(
                  key: const ValueKey('typing'),
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) => _dot(i)),
                )
              : RichText(
                  key: const ValueKey('text'),
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                    children: _parseFormattedText(text),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _inputBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color.fromARGB(21, 0, 0, 0).withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TextField(
                  style: GoogleFonts.poppins(color: Colors.black87),
                  controller: _ctrl,
                  decoration: InputDecoration(
                    hintText: 'Tulis pesan...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF4e8cff), // Warna biru latar belakang
                  shape: BoxShape.circle, // Bentuk bulat
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white, // Ikon putih
                  size: 20, // Ukuran ikon bisa diatur
                ),
              ),
            ),
          ],
        ),
      );

  Widget _dot(int index) {
    final delay = index * 200;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1),
      duration: Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (_, v, __) => Opacity(
        opacity: v,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            '•',
            style: GoogleFonts.poppins(fontSize: 20, color: Colors.black87),
          ),
        ),
      ),
      onEnd: () {},
    );
  }
}

enum Role { user, bot }

class _Msg {
  final String text;
  final Role role;
  _Msg(this.text, this.role);
}
