import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:active/controllers/api_constants.dart';

class GeminiService {
  final List<Map<String, dynamic>> chatHistory = [];

  Future<String> generateResponse(String prompt) async {
    try {
      final response = await sendPrompt(prompt);
      return response;
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<String> sendPrompt(String prompt) async {
    chatHistory.add({
      'role': 'user',
      'parts': [
        {'text': prompt}
      ]
    });

    final body = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'text': 'Kamu adalah Acto, chatbot self-care yang ramah. '
                  'Gunakan bahasa santai, dan gunakan format **bold**, *italic*, atau __underline__ jika perlu. '
                  'Jawablah dengan singkat, maksimal 2-3 kalimat.'
            }
          ]
        },
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

    chatHistory.add({
      'role': 'model',
      'parts': [
        {'text': reply}
      ]
    });

    return reply;
  }
}
