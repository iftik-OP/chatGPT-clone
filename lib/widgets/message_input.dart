import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../consts/app_colors.dart';
import '../models/ai_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MessageInput extends StatefulWidget {
  const MessageInput({super.key});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  void _send() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && _selectedImage == null) {
      Provider.of<ChatProvider>(context, listen: false).sendMessage(text);
      setState(() {
        _controller.clear();
      });
    }
    if (_selectedImage != null) {
      Provider.of<ChatProvider>(context, listen: false)
          .sendImageForAnalysis(_selectedImage!, text: text);
      setState(() {
        _selectedImage = null;
      });
      _controller.clear();
    } 
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  IconData _getModelIcon(String provider) {
    switch (provider.toLowerCase()) {
      case 'openai':
        return Icons.smart_toy;
      case 'anthropic':
        return Icons.psychology;
      case 'google':
        return Icons.explore;
      default:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final selectedModel = chatProvider.selectedModel;
        
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        _getModelIcon(selectedModel.provider),
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedModel.name,
                        style: const TextStyle(
                          color: AppColors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (selectedModel.supportsVision)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Vision',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          right: 4,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputField,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        color: AppColors.iconGray,
                        onPressed: selectedModel.supportsVision ? _pickImage : null,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Ask anything',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: AppColors.white70, fontSize: 16),
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          onSubmitted: (_) => _send(),
                          onChanged: (value) {
                            setState(() {
                              _controller.text = value;
                            });
                          },
                        ),
                      ),
                      _controller.text.isNotEmpty 
                        ? IconButton( 
                            icon: const Icon(Icons.arrow_upward),
                            color: AppColors.primary,
                            onPressed: _send,
                          ) 
                        : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 