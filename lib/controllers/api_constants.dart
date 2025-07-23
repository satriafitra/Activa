import 'package:flutter_dotenv/flutter_dotenv.dart';

final String kGeminiApiKey = dotenv.env['GEMINI_API_KEY']!;
final String kGeminiModel = dotenv.env['GEMINI_MODEL']!;
final String kEndpoint =
    'https://generativelanguage.googleapis.com/v1/models/$kGeminiModel:generateContent?key=$kGeminiApiKey';
