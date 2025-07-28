import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:active/controllers/api_constants.dart';

class GeminiService {
  final List<Map<String, dynamic>> chatHistory = [];

  Future<String> sendPrompt(String prompt) async {
    // Tambahkan pesan user ke riwayat obrolan
    chatHistory.add({
      'role': 'user',
      'parts': [
        {'text': prompt}
      ]
    });

    final body = {
      'contents': [
        // Prompt karakter Acto tetap di awal agar konsisten
        {
          'role': 'user',
          'parts': [
            {
              'text': 'Kamu adalah Acto, chatbot self-care yang ceria, hangat, '
                  'tidak menghakimi, dan suka menyemangati user untuk menyelesaikan kebiasaan positif. '
                  'Gunakan bahasa santai dan menyenangkan, dan gunakan format **bold**, *italic*, atau __underline__ jika perlu.'
            }
          ]
        },
        // Tambahkan history secara bertahap
        ...chatHistory,
      ]
    };

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

    // Tambahkan respons Acto ke riwayat obrolan
    chatHistory.add({
      'role': 'model',
      'parts': [
        {'text': reply}
      ]
    });

    return reply;
  }
}
