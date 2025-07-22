import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/conversation.dart';

class MongoService {
  Db? _db;
  DbCollection? _collection;
  bool _isConnected = false;

  final collectionName = 'collections';

  Db get db {
    if (_db == null) {
      throw StateError('Database not connected. Call connect() first.');
    }
    return _db!;
  }

  DbCollection get collection {
    if (_collection == null) {
      throw StateError('Collection not available. Call connect() first.');
    }
    return _collection!;
  }

  Future<void> connect() async {
    if (_isConnected && _db != null) {
      print('[MongoDB] Already connected, skipping connection.');
      return;
    }

    try {
      final uri = dotenv.env['MONGODB_URI']!;
      // final dbName = dotenv.env['MONGODB_DATABASE']!;
      _db = Db('mongodb://192.168.10.18:27017/config');
      await _db!.open();
      _collection = _db!.collection(collectionName);
      _isConnected = true;
      print('[MongoDB] Connected successfully.');
    } catch (e) {
      print('[MongoDB] Connection error: $e');
      _isConnected = false;
      rethrow;
    }
  }

  Future<void> open() async {
    await connect();
  }

  Future<List<Conversation>> getConversations() async {
    if (!_isConnected) {
      await connect();
    }
    final docs = await collection.find().toList();
    return docs.map((doc) => Conversation.fromJson(doc)).toList();
  }

  Future<void> saveConversation(Conversation conversation) async {
    if (!_isConnected) {
      await connect();
    }
    try {
      await collection.insertOne(conversation.toJson());
    } catch (e) {
      print('[MongoDB] Error saving conversation: $e');
      rethrow;
    }
  }

  Future<void> updateConversation(Conversation conversation) async {
    if (!_isConnected) {
      await connect();
    }
    await collection.replaceOne(
      where.eq('id', conversation.id),
      conversation.toJson(),
      upsert: true, // If it doesn't exist, insert it
    );
  }

  Future<void> deleteConversation(String conversationId) async {
    if (!_isConnected) {
      await connect();
    }
    try {
      await collection.deleteOne(where.eq('id', conversationId));
      print('[MongoDB] Conversation deleted successfully: $conversationId');
    } catch (e) {
      print('[MongoDB] Error deleting conversation: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    if (_db != null && _isConnected) {
      try {
        await _db!.close();
        _isConnected = false;
        print('[MongoDB] Connection closed successfully.');
      } catch (e) {
        print('[MongoDB] Error closing connection: $e');
      }
    }
  }
} 