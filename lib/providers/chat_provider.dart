import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../models/ai_model.dart';
import '../services/chatgpt_service.dart';
import '../services/mongo_service.dart';
import '../services/cloudinary_service.dart';
import '../services/image_compression_service.dart';
import 'dart:io';

class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  bool _isLoading = false;
  final ChatGPTService _chatgptService = ChatGPTService();
  final MongoService _mongoService = MongoService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImageCompressionService _compressionService = ImageCompressionService();
  bool _conversationsLoaded = false;

  List<Conversation> _conversations = [];
  Conversation? _selectedConversation;
  AIModel _selectedModel = ModelConfiguration.defaultModel;

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  List<Conversation> get conversations => _conversations;
  Conversation? get selectedConversation => _selectedConversation;
  AIModel get selectedModel => _selectedModel;

  Future<void> loadConversations() async {
    if (_conversationsLoaded) {
      print('[MongoDB] Conversations already loaded, skipping.');
      return;
    }

    print('[MongoDB] Loading conversations...');
    try {
      await _mongoService.connect();
      _conversations = await _mongoService.getConversations();
      _conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      print('[MongoDB] Loaded conversations: ${_conversations.length}');
      _conversationsLoaded = true;
    } catch (e) {
      print('[MongoDB] Error loading conversations: $e');
      _loadMockConversations();
      _conversationsLoaded = true;
    } finally {
      notifyListeners();
    }
  }

  void _loadMockConversations() {
    print('[MongoDB] Loading mock conversations for testing...');
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    final weekAgo = now.subtract(const Duration(days: 7));

    _conversations = [
      Conversation(
        id: '1',
        timestamp: now.subtract(const Duration(hours: 2)),
        modelUsed: 'gpt-4',
        messages: [
          Message(text: 'How do I implement state management in Flutter?', sender: MessageSender.user),
          Message(text: 'Flutter provides several options for state management. The most common approaches are:\n\n1. **Provider** - Simple and recommended by Flutter team\n2. **Bloc** - For complex state management\n3. **Riverpod** - Modern alternative to Provider\n4. **GetX** - All-in-one solution\n\nFor your use case, I\'d recommend starting with Provider as it\'s easy to learn and powerful enough for most apps.', sender: MessageSender.ai),
        ],
        uploadedImages: [],
      ),
      Conversation(
        id: '2',
        timestamp: yesterday,
        modelUsed: 'gpt-4',
        messages: [
          Message(text: 'What are the best practices for UI design?', sender: MessageSender.user),
          Message(text: 'Here are some key UI design best practices:\n\n1. **Consistency** - Use consistent colors, fonts, and spacing\n2. **Hierarchy** - Establish clear visual hierarchy\n3. **Accessibility** - Ensure your app is accessible to all users\n4. **Feedback** - Provide clear feedback for user actions\n5. **Simplicity** - Keep interfaces clean and uncluttered\n6. **Responsive** - Design for different screen sizes', sender: MessageSender.ai),
        ],
        uploadedImages: [],
      ),
      Conversation(
        id: '3',
        timestamp: twoDaysAgo,
        modelUsed: 'gpt-4',
        messages: [
          Message(text: 'Explain async programming in Dart', sender: MessageSender.user),
          Message(text: 'Async programming in Dart allows you to write non-blocking code. Here\'s how it works:\n\n**Future**: Represents a value or error that will be available at some time in the future.\n**async/await**: Keywords that make asynchronous code easier to read and write.\n\nExample:\n```dart\nFuture<String> fetchData() async {\n  await Future.delayed(Duration(seconds: 2));\n  return "Data loaded!";\n}\n```', sender: MessageSender.ai),
        ],
        uploadedImages: [],
      ),
      Conversation(
        id: '4',
        timestamp: weekAgo,
        modelUsed: 'gpt-4',
        messages: [
          Message(text: 'How to deploy a Flutter app?', sender: MessageSender.user),
          Message(text: 'To deploy a Flutter app, follow these steps:\n\n**Android**:\n1. Run `flutter build apk` or `flutter build appbundle`\n2. Upload to Google Play Console\n\n**iOS**:\n1. Run `flutter build ios`\n2. Open in Xcode and archive\n3. Upload to App Store Connect\n\n**Web**:\n1. Run `flutter build web`\n2. Deploy the build/web folder to your hosting service', sender: MessageSender.ai),
        ],
        uploadedImages: [],
      ),
    ];
    
    _conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void createNewConversation() {
    _selectedConversation = null;
    _messages.clear();
    notifyListeners();
  }

  void setSelectedModel(AIModel model) {
    _selectedModel = model;
    notifyListeners();
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _mongoService.deleteConversation(conversationId);
      _conversations.removeWhere((conv) => conv.id == conversationId);
      
      if (_selectedConversation?.id == conversationId) {
        _selectedConversation = null;
        _messages.clear();
      }
      
      notifyListeners();
    } catch (e) {
      print('[MongoDB] Error deleting conversation: $e');
      _conversations.removeWhere((conv) => conv.id == conversationId);
      
      if (_selectedConversation?.id == conversationId) {
        _selectedConversation = null;
        _messages.clear();
      }
      
      notifyListeners();
    }
  }

  Future<void> saveCurrentConversation({required String modelUsed, List<String>? uploadedImages}) async {
    if (_messages.isEmpty) return;
    
    final isNew = _selectedConversation == null;

    final cloudImageUrls = <String>[];
    for (final message in _messages) {
      if (message.isImageFromCloud && message.imageUrl != null) {
        cloudImageUrls.add(message.imageUrl!);
      }
    }

    final conversation = Conversation(
      id: isNew ? DateTime.now().millisecondsSinceEpoch.toString() : _selectedConversation!.id,
      timestamp: isNew ? DateTime.now() : _selectedConversation!.timestamp,
      modelUsed: modelUsed,
      messages: List<Message>.from(_messages),
      uploadedImages: uploadedImages ?? cloudImageUrls,
    );

    if (isNew) {
      _selectedConversation = conversation;
      _conversations.insert(0, conversation);
    }

    print('[MongoDB] ${isNew ? 'Inserting' : 'Updating'} conversation: ${conversation.toJson()}');

    try {
      if (isNew) {
        await _mongoService.saveConversation(conversation);
      } else {
        await _mongoService.updateConversation(conversation);
      }
      print('[MongoDB] Conversation ${isNew ? 'saved' : 'updated'} successfully.');
    } catch (e) {
      print('[MongoDB] Error saving conversation: ${e.toString()}');
      if (!isNew) {
        final index = _conversations.indexWhere((conv) => conv.id == conversation.id);
        if (index != -1) {
          _conversations[index] = conversation;
        }
      }
    } finally {
      notifyListeners();
    }
  }

  void selectConversation(Conversation conversation) {
    _selectedConversation = conversation;
    _messages
      ..clear()
      ..addAll(conversation.messages);
    _selectedModel = ModelConfiguration.getModelById(conversation.modelUsed);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _selectedConversation = null;
    notifyListeners();
  }

  String _getConversationTitle(Conversation conversation) {
    if (conversation.messages.isEmpty) return 'New conversation';
    
    final firstUserMessage = conversation.messages.firstWhere(
      (msg) => msg.sender == MessageSender.user,
      orElse: () => Message(text: 'New conversation', sender: MessageSender.user),
    );
    
    String title = firstUserMessage.text;
    if (title.length > 50) {
      title = '${title.substring(0, 50)}...';
    }
    return title.isEmpty ? 'New conversation' : title;
  }

  String getConversationTitle(Conversation conversation) {
    return _getConversationTitle(conversation);
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String getTimeAgo(Conversation conversation) {
    return _getTimeAgo(conversation.timestamp);
  }

  List<Conversation> getConversationsByDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    return _conversations.where((conv) {
      final convDate = DateTime(conv.timestamp.year, conv.timestamp.month, conv.timestamp.day);
      return convDate.isAfter(weekAgo);
    }).toList();
  }

  void sendMessage(String text) {
    _messages.add(Message(text: text, sender: MessageSender.user));
    notifyListeners();
    _getChatGPTResponse(text, model: _selectedModel.id);
    _autoSave();
  }

  Future<void> sendImageForAnalysis(File imageFile, {String text = ''}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!_cloudinaryService.isConfigured()) {
        print('[Cloudinary] Warning: Using default configuration. Consider setting up proper Cloudinary credentials.');
      }

      print('[ImageCompression] Starting image compression...');
      final File compressedImage = await _compressionService.compressImageSmart(imageFile);
      print('[ImageCompression] Image compression completed');

      print('[Cloudinary] Uploading compressed image to cloud...');
      final cloudUrl = await _cloudinaryService.uploadImage(compressedImage);
      print('[Cloudinary] Image uploaded successfully: $cloudUrl');

      _messages.add(Message(
        text: text, 
        sender: MessageSender.user, 
        imageUrl: cloudUrl,
        isImageFromCloud: true,
      ));
      _messages.add(Message(
        text: text, 
        sender: MessageSender.user, 
        
      ));
      
      notifyListeners();

      final aiText = await _chatgptService.sendImageForAnalysis(
        imageFile,
        prompt: text,
        model: _selectedModel.id,
      );
      _messages.add(Message(text: aiText, sender: MessageSender.ai));
      _autoSave();

      try {
        await compressedImage.delete();
        print('[ImageCompression] Temporary file cleaned up');
      } catch (e) {
        print('[ImageCompression] Error cleaning up temp file: $e');
      }

    } catch (e) {
      print('[ImageProcessing] Error processing image: $e');
      _messages.add(Message(
        text: text, 
        sender: MessageSender.user, 
        imagePath: imageFile.path,
        isImageFromCloud: false,
      ));
      _messages.add(Message(
        text: 'Error processing image. Using local storage. Error: $e', 
        sender: MessageSender.ai
      ));
      _autoSave();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getChatGPTResponse(String prompt, {String? model}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final aiText = await _chatgptService.sendMessage(prompt, model: model ?? _selectedModel.id);
      _messages.add(Message(text: aiText, sender: MessageSender.ai));
      _autoSave();
    } catch (e) {
      _messages.add(Message(text: 'Error: $e', sender: MessageSender.ai));
      _autoSave();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _autoSave() async {
    print('[MongoDB] Auto-saving conversation...');
    await saveCurrentConversation(modelUsed: _selectedModel.id);
  }

  @override
  void dispose() {
    _mongoService.close();
    _compressionService.cleanupTempFiles();
    super.dispose();
  }
} 