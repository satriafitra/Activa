// gemini_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:active/controllers/api_constants.dart';

class GeminiService {
  Future<String> sendPrompt(String prompt) async {
    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
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
    return reply;
  }
}
