// gemini_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:active/controllers/api_constants.dart';

class GeminiService {
  List<Map<String, String>> chatHistory = [];

  Future<String> sendPrompt(String prompt) async {
    // Tambahkan prompt terbaru ke chat history
    chatHistory.add({"role": "user", "text": prompt});

    final body = {
      'contents': chatHistory.map((message) => {
            'role': message['role'] == 'user' ? 'user' : 'model',
            'parts': [
              {'text': message['text']!}
            ]
          }).toList()
    };

    // Tambahkan instruksi karakter di awal jika history kosong
    if (chatHistory.isEmpty ||
        chatHistory.first['text']
            ?.contains('Acto') !=
            true) {
      chatHistory.insert(0, {
        'role': 'model',
        'text':
            'Kamu adalah Acto, chatbot self-care yang ceria, hangat, tidak menghakimi, dan suka menyemangati user untuk menyelesaikan kebiasaan positif. Gunakan bahasa santai dan menyenangkan.'
      });
    }

    final res = await http.post(
      Uri.parse(kEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body);
    if (data['error'] != null) {
      throw Exception('${data['error']['message']}');
    }

    final reply = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
    if (reply == null || reply.isEmpty) throw Exception('Empty response');

    // Tambahkan balasan ke history
    chatHistory.add({"role": "model", "text": reply});

    return reply;
  }
}

