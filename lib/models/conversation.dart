import 'package:mongo_dart/mongo_dart.dart';
import 'message.dart';

class Conversation {
  final String id;
  final DateTime timestamp;
  final String modelUsed;
  final List<Message> messages;
  final List<String> uploadedImages;

  Conversation({
    required this.id,
    required this.timestamp,
    required this.modelUsed,
    required this.messages,
    required this.uploadedImages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'] ?? '',
    timestamp: DateTime.parse(json['timestamp']),
    modelUsed: json['modelUsed'],
    messages: (json['messages'] as List).map((m) => Message.fromJson(m)).toList(),
    uploadedImages: List<String>.from(json['uploadedImages'] ?? []),
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'modelUsed': modelUsed,
      'messages': messages.map((m) => m.toJson()).toList(),
      'uploadedImages': uploadedImages,
    };
  }
}
