import 'package:flutter/material.dart';

class AnimatedTextWidget extends StatefulWidget {
  final List<String> texts; // List of texts to animate
  final TextStyle? textStyle; // Customizable text style
  final Duration duration; // Duration for animation cycle

  const AnimatedTextWidget({
    Key? key,
    required this.texts,
    this.textStyle,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  _AnimatedTextWidgetState createState() => _AnimatedTextWidgetState();
}

class _AnimatedTextWidgetState extends State<AnimatedTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _textAnimationController;
  late Animation<Offset> _textPositionAnimation;
  late Animation<double> _textFadeAnimation;

  int currentTextIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _textAnimationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Define position and fade animations
    _textPositionAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset(0, -0.3),
    ).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeInOut),
    );

    _textFadeAnimation = Tween<double>(begin: 0.9, end: 0.0).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeIn),
    );

    _startTextAnimation();
  }

  void _startTextAnimation() {
    Future.delayed(Duration(seconds: 1), () {
      _textAnimationController.forward().whenComplete(() {
        Future.delayed(Duration(milliseconds: 200), () {
          setState(() {
            // Update the index for the next text
            currentTextIndex = (currentTextIndex + 1) % widget.texts.length;
          });
          _textAnimationController.reset();
          _textAnimationController.forward(from: 0.0);
          _startTextAnimation();
        });
      });
    });
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _textAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _textFadeAnimation.value,
          child: Transform.translate(
            offset: _textPositionAnimation.value * 200,
            child: Text(
              widget.texts[currentTextIndex],
              textAlign: TextAlign.center,
              style: widget.textStyle ??
                  TextStyle(
                    fontSize: 17,
                    color: Colors.orange,
                    fontWeight: FontWeight.w200,
                    fontFamily: 'Inter',
                  ),
            ),
          ),
        );
      },
    );
  }
}
