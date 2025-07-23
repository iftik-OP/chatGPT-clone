import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatGPTService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> sendMessage(String prompt, {String model = 'gpt-3.5-turbo'}) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 1024,
        'temperature': 0.7,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices']?[0]?['message']?['content'] ?? 'No response';
    } else {
      throw Exception('Failed to get response: ${response.body}');
    }
  }

  Future<String> sendImageForAnalysis(
    File imageFile, {
    String? prompt,
    String model = 'gpt-4.1-mini', 
  }) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final List<Map<String, dynamic>> content = [
      if (prompt != null && prompt.isNotEmpty)
        {'type': 'text', 'text': prompt},
      {
        'type': 'image_url',
        'image_url': {
          'url': 'data:image/jpeg;base64,$base64Image',
        }
      }
    ];

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': content,
          }
        ],
        'max_tokens': 300,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices']?[0]?['message']?['content'] ?? 'No response';
    } else {
      throw Exception('Failed to get image analysis: ${response.body}');
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': 'Hello'}
          ],
          'max_tokens': 5,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
} 