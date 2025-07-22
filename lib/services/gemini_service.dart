import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  Future<String> sendMessage(String prompt, {String model = 'gemini-1.5-flash'}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$model:generateContent?key=$_apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'maxOutputTokens': 1024,
          'temperature': 0.7,
        }
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'No response';
    } else {
      throw Exception('Failed to get response: ${response.body}');
    }
  }
} 