import 'dart:io';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../consts/app_colors.dart';

TextSpan formatText(String text, TextStyle defaultStyle) {
  final List<TextSpan> spans = [];
  final RegExp boldExp = RegExp(r'\*\*(.*?)\*\*');
  final RegExp bulletExp = RegExp(r'^\* (.*)', multiLine: false);

  final lines = text.split('\n');
  for (var line in lines) {
    final bulletMatch = bulletExp.firstMatch(line);
    if (bulletMatch != null) {
      spans.add(TextSpan(
        text: '\u2022 ',
        style: defaultStyle.copyWith(fontWeight: FontWeight.bold),
      ));
      line = bulletMatch.group(1)!;
    }

    int currentIndex = 0;
    final matches = boldExp.allMatches(line);
    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: line.substring(currentIndex, match.start),
          style: defaultStyle,
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: defaultStyle.copyWith(fontWeight: FontWeight.bold),
      ));
      currentIndex = match.end;
    }
    if (currentIndex < line.length) {
      spans.add(TextSpan(
        text: line.substring(currentIndex),
        style: defaultStyle,
      ));
    }
    spans.add(const TextSpan(text: '\n'));
  }
  return TextSpan(children: spans);
}

class ChatBubble extends StatelessWidget {
  final Message message;
  const ChatBubble({super.key, required this.message});

  Widget _buildImageWidget() {
    final imageSource = message.imageSource;
    if (imageSource == null) return const SizedBox.shrink();

    if (message.isImageFromCloud) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          imageSource,
          width: 180,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 180,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / 
                        loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.primary,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 180,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 32,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(
          File(imageSource),
          width: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 180,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 32,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final hasImage = message.imageSource != null;
    
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          margin: EdgeInsets.only(
            top: 4,
            bottom: 4,
            left: isUser ? 40 : 12,
            right: isUser ? 12 : 40,
          ),
          padding: EdgeInsets.symmetric(
            vertical: hasImage ? 0 : 14, 
            horizontal: hasImage ? 0 : isUser ? 18 : 8
          ),
          decoration: BoxDecoration(
            color: isUser ? AppColors.userBubble : AppColors.aiBubble,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: hasImage
              ? _buildImageWidget()
              : (isUser
                  ? Text(
                      message.text,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 17,
                        height: 1.3,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.left,
                    )
                  : RichText(
                      text: formatText(
                        message.text,
                        const TextStyle(
                          color: AppColors.white,
                          fontSize: 17,
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      textAlign: TextAlign.left,
                    )
                ),
        ),
      ],
    );
  }
} 