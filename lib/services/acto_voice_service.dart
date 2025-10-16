import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:active/services/gemini_service.dart';

class ActoVoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final GeminiService _gemini = GeminiService();

  bool _isListening = false;
  String _lastCaptured = '';

  /// 🎤 Mulai mendengarkan suara pengguna
  Future<void> startListening(Function(String text) onTextCaptured) async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("🎧 Status: $status"),
      onError: (error) => print("❌ Error: $error"),
    );

    if (!available) {
      print("⚠️ Speech recognition tidak tersedia.");
      return;
    }

    _isListening = true;
    _speech.listen(
      listenMode: stt.ListenMode.dictation,
      onResult: (result) {
        _lastCaptured = result.recognizedWords;
        if (result.finalResult && _lastCaptured.isNotEmpty) {
          print("🎙️ Final: $_lastCaptured");
          onTextCaptured(_lastCaptured);
        }
      },
    );
  }

  /// 🛑 Berhenti mendengarkan
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      print("🛑 Stopped listening");
    }
  }

  /// 🔊 Fungsi untuk bicara
  Future<void> speak(String text) async {
    await _tts.stop(); // pastikan tts lama berhenti dulu
    await _tts.setLanguage("id-ID");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);

    // Pilih suara yang tersedia
    try {
      var voices = await _tts.getVoices;
      print("🗣️ Voices: $voices");

      // Pilih suara Indonesia jika ada
      var voice = voices.firstWhere(
        (v) => v['locale'] == 'id-ID',
        orElse: () => voices.first,
      );
      await _tts.setVoice({
        "name": voice['name'],
        "locale": voice['locale'],
      });
    } catch (e) {
      print("⚠️ Tidak bisa memilih voice: $e");
    }

    print("🔊 Speaking: $text");
    await _tts.speak(text);
  }

  /// 🧠 Proses utama: dengar → kirim ke Gemini → jawab + bicara
  Future<void> processVoice(
      Function(String user, String acto) onChatUpdated) async {
    _lastCaptured = '';

    await startListening((text) {
      _lastCaptured = text;
    });

    // Tunggu pengguna bicara maksimal 6 detik
    await Future.delayed(const Duration(seconds: 6));
    await stopListening();

    if (_lastCaptured.isNotEmpty) {
      print("📩 Mengirim ke Gemini: $_lastCaptured");

      final reply = await _gemini.generateResponse(_lastCaptured);
      print("🤖 Jawaban Gemini: $reply");

      onChatUpdated(_lastCaptured, reply);
      await speak(reply);
    } else {
      print("⚠️ Tidak ada suara yang tertangkap.");
    }
  }
}
