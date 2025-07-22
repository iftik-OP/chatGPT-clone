import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/conversation.dart';

class MongoDBService {
  final String apiKey = dotenv.env['MONGODB_DATA_API_KEY'] ?? '';
  final String endpoint = dotenv.env['MONGODB_DATA_API_ENDPOINT'] ?? '';
  final String dataSource = dotenv.env['MONGODB_DATA_SOURCE'] ?? 'Cluster0';
  final String database = dotenv.env['MONGODB_DATABASE'] ?? 'chatgpt_clone';
  final String collection = dotenv.env['MONGODB_COLLECTION'] ?? 'conversations';

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'api-key': apiKey,
  };

  Future<List<Conversation>> getConversations() async {
    final url = Uri.parse('$endpoint/action/find');
    final body = jsonEncode({
      'dataSource': dataSource,
      'database': database,
      'collection': collection,
      'sort': {'timestamp': -1}
    });
    final res = await http.post(url, headers: headers, body: body);
    if (res.statusCode == 200) {
      final docs = jsonDecode(res.body)['documents'] as List;
      return docs.map((doc) => Conversation.fromJson(doc)).toList();
    } else {
      throw Exception('Failed to fetch conversations: ${res.body}');
    }
  }

  Future<void> saveConversation(Conversation conversation) async {
    final url = Uri.parse('$endpoint/action/insertOne');
    final body = jsonEncode({
      'dataSource': dataSource,
      'database': database,
      'collection': collection,
      'document': conversation.toJson(),
    });
    final res = await http.post(url, headers: headers, body: body);
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to save conversation: ${res.body}');
    }
  }
} 