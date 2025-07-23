import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../models/message.dart';
import '../consts/app_colors.dart';

class StreamingChatBubble extends StatefulWidget {
  final Message message;
  final VoidCallback? onStreamingComplete;

  const StreamingChatBubble({
    super.key, 
    required this.message,
    this.onStreamingComplete,
  });

  @override
  State<StreamingChatBubble> createState() => _StreamingChatBubbleState();
}

class _StreamingChatBubbleState extends State<StreamingChatBubble> {
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    // Always animate AI messages for now
    if (widget.message.sender == MessageSender.ai) {
      _isAnimating = true;
    }
  }

  @override
  void didUpdateWidget(StreamingChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the message text changed and it's an AI message, start animation
    if (widget.message.sender == MessageSender.ai && 
        widget.message.text != oldWidget.message.text) {
      _isAnimating = true;
    }
  }

  Widget _buildImageWidget() {
    final imageSource = widget.message.imageSource;
    if (imageSource == null) return const SizedBox.shrink();

    if (widget.message.isImageFromCloud) {
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
    final isUser = widget.message.sender == MessageSender.user;
    final hasImage = widget.message.imageSource != null;
    
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
                      widget.message.text,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 17,
                        height: 1.3,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.left,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isAnimating
                            ? AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    widget.message.text,
                                    textStyle: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 17,
                                      height: 1.3,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    speed: const Duration(milliseconds: 5),
                                  ),
                                ],
                                totalRepeatCount: 1,
                                displayFullTextOnTap: true,
                                stopPauseOnTap: true,
                                onTap: () {
                                  // Stop animation and show full text
                                  setState(() {
                                    _isAnimating = false;
                                  });
                                },
                                onNext: (index, isLast) {
                                  if (isLast) {
                                    setState(() {
                                      _isAnimating = false;
                                    });
                                    widget.onStreamingComplete?.call();
                                  }
                                },
                              )
                            : RichText(
                                text: formatText(
                                  widget.message.text,
                                  const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 17,
                                    height: 1.3,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                textAlign: TextAlign.left,
                              ),
                        if (_isAnimating) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white54,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white54,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white54,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    )
                ),
        ),
      ],
    );
  }
}

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