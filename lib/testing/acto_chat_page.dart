import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:active/services/gemini_service.dart';

class ActoVoicePage extends StatefulWidget {
  const ActoVoicePage({super.key});

  @override
  State<ActoVoicePage> createState() => _ActoVoicePageState();
}

class _ActoVoicePageState extends State<ActoVoicePage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final GeminiService _gemini = GeminiService();

  bool _isListening = false;
  bool _isSpeaking = false;
  double _amplitude = 0.0;
  Timer? _timer;

  // === 🔊 INISIALISASI SUARA (TTS) ===
  Future<void> _initTts() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('id-ID');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.55);
    await _tts.setVolume(1.0);

    var voices = await _tts.getVoices;
    if (voices.toString().contains("id-ID")) {
      await _tts.setVoice({"name": "id-id-x-ida-local", "locale": "id-ID"});
    }

    // Setelah Acto selesai bicara, otomatis dengarkan lagi
    _tts.setCompletionHandler(() async {
      debugPrint("🔁 Acto selesai bicara, mulai mendengarkan lagi...");
      setState(() => _isSpeaking = false);
      if (_isListening) await _startListening();
    });
  }

  Future<void> _speak(String text) async {
    setState(() => _isSpeaking = true);
    await _tts.speak(text);
  }

  // === 🎙️ MULAI MENDENGARKAN ===
  Future<void> _startListening() async {
    if (_isSpeaking) return; // Jangan dengar saat Acto bicara

    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('🎧 Status: $status'),
      onError: (error) => debugPrint('❌ Error: $error'),
    );

    if (available) {
      setState(() => _isListening = true);

      _speech.listen(
        listenMode: stt.ListenMode.dictation,
        pauseFor: const Duration(seconds: 2),
        onResult: (val) async {
          if (val.finalResult && val.recognizedWords.isNotEmpty) {
            debugPrint('🗣️ Final transcript: ${val.recognizedWords}');
            await _sendToAI(val.recognizedWords);
          }
        },
        onSoundLevelChange: (level) {
          setState(() {
            _amplitude = level.clamp(0, 50) / 50;
          });
        },
      );

      // Animasi bar mic
      _timer = Timer.periodic(const Duration(milliseconds: 150), (_) {
        if (!_isListening) return;
        setState(() {
          _amplitude = _amplitude * 0.8;
        });
      });
    } else {
      debugPrint('❌ Speech recognition not available');
    }
  }

  // === 💬 KIRIM KE AI DAN PUTAR SUARA ===
  Future<void> _sendToAI(String text) async {
    await _stopListening();
    debugPrint('🤖 Sending to AI: $text');

    final response = await _gemini.generateResponse(text);
    debugPrint('💬 AI Response: $response');

    await _initTts();
    await _speak(response);
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    _timer?.cancel();
    setState(() {
      _isListening = false;
      _amplitude = 0.0;
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildVoiceBars() {
    final bars = List.generate(4, (index) {
      final height = 40 + (_amplitude * 60 * (1 + index * 0.1));
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 20,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3F6),
          borderRadius: BorderRadius.circular(12),
        ),
      );
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: bars,
    );
  }

  @override
  Widget build(BuildContext context) {
    final micActive = _isListening && !_isSpeaking;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Acto Voice Mode',
          style: TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            _buildVoiceBars(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (!micActive) {
                        await _startListening();
                      } else {
                        await _stopListening();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: micActive ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (micActive ? Colors.green : Colors.red)
                                .withOpacity(0.5),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        micActive ? Icons.mic : Icons.mic_off,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  GestureDetector(
                    onTap: _stopListening,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF3F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
