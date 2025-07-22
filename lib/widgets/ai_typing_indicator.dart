import 'package:flutter/material.dart';

class AITypingIndicator extends StatefulWidget {
  const AITypingIndicator({super.key});

  @override
  State<AITypingIndicator> createState() => _AITypingIndicatorState();
}

class _AITypingIndicatorState extends State<AITypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        int dots = (_animation.value).floor() + 1;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: i < dots ? 1.0 : 0.3,
                child: const Text(
                  '.',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 