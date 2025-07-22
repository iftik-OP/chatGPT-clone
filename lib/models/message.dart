enum MessageSender { user, ai }

class Message {
  final String text;
  final MessageSender sender;
  final String? imagePath;
  final String? imageUrl;
  final bool isImageFromCloud;

  Message({
    required this.text, 
    required this.sender, 
    this.imagePath,
    this.imageUrl,
    this.isImageFromCloud = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    text: json['text'],
    sender: json['sender'] == 'user' ? MessageSender.user : MessageSender.ai,
    imagePath: json['imagePath'],
    imageUrl: json['imageUrl'],
    isImageFromCloud: json['isImageFromCloud'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'text': text,
    'sender': sender == MessageSender.user ? 'user' : 'ai',
    'imagePath': imagePath,
    'imageUrl': imageUrl,
    'isImageFromCloud': isImageFromCloud,
  };

  String? get imageSource => isImageFromCloud ? imageUrl : imagePath;
} 