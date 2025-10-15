import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:active/services/gemini_service.dart';

class ActoVoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final GeminiService _gemini = GeminiService();

  bool _isListening = false;

  Future<void> startListening(Function(String text) onTextCaptured) async {
    bool available = await _speech.initialize();
    if (available) {
      _isListening = true;
      _speech.listen(onResult: (result) {
        print("🎙️ Captured text: ${result.recognizedWords}");
        onTextCaptured(result.recognizedWords);
      });
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  Future<void> speak(String text) async {
    await _tts.setLanguage("id-ID"); // Bahasa Indonesia
    await _tts.setPitch(1); // Nada suara (0.5 = berat, 2.0 = tinggi)
    await _tts.setSpeechRate(0.5); // Kecepatan bicara (0.5–1.0)
    await _tts.setVolume(1.0); // Volume (0.0–1.0)

    // Pilih suara (tergantung device support)
    var voices = await _tts.getVoices;
    print("🗣️ Available voices: $voices");

    // Contoh: pilih suara wanita Indonesia (kalau tersedia)
    await _tts.setVoice({"name": "id-id-x-ida-local", "locale": "id-ID"});

    await _tts.speak(text);
  }

  Future<void> processVoice(
      Function(String user, String acto) onChatUpdated) async {
    String captured = '';
    await startListening((text) {
      captured = text;
    });

    // Tunggu 5 detik lalu hentikan
    await Future.delayed(const Duration(seconds: 5));
    await stopListening();

    if (captured.isNotEmpty) {
      // Panggil Gemini API
      final reply = await _gemini.sendPrompt(captured);
      onChatUpdated(captured, reply);
      await speak(reply);
    }
  }
}
