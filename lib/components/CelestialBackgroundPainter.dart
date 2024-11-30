import 'dart:math';
import 'package:flutter/material.dart';

class CelestialBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  
  // List to store fixed star positions, size, and opacity
  final List<Star> stars;

  CelestialBackgroundPainter(this.animation, this.stars) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.5) // Base color for the stars
      ..style = PaintingStyle.fill;

    // Generate the stars at fixed positions with twinkling effect
    for (int i = 0; i < stars.length; i++) {
      final star = stars[i];
      
      // Dynamic twinkling effect using sine wave for opacity
      double opacity = 0.5 + sin(animation.value * 2 * pi * star.flickerSpeed + i) * 0.5;

      // Set the opacity and adjust size for each star
      paint.color = Colors.white.withOpacity(opacity);
      
      // Draw the stars with varying opacity and size
      canvas.drawCircle(star.position, star.size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Repaint whenever the animation changes
  }
}

class Star {
  final Offset position;
  final double size;
  final double flickerSpeed;

  Star({
    required this.position,
    required this.size,
    required this.flickerSpeed,
  });
}

class CelestialBackground extends StatefulWidget {
  @override
  _CelestialBackgroundState createState() => _CelestialBackgroundState();
}

class _CelestialBackgroundState extends State<CelestialBackground> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Star> stars;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Generate random stars with positions, sizes, and flicker speeds
    stars = _generateRandomStars();
  }

  // Generate 20 random stars with size and flicker speed
  List<Star> _generateRandomStars() {
    final Random random = Random();
    List<Star> starList = [];
    for (int i = 0; i < 20; i++) {
      double x = random.nextDouble() * 500; // Random X position
      double y = random.nextDouble() * 500; // Random Y position
      double size = 1 + random.nextDouble() * 2; // Random size between 1 and 3
      double flickerSpeed = 0.5 + random.nextDouble(); // Random flicker speed (0.5 - 1.5)
      starList.add(Star(position: Offset(x, y), size: size, flickerSpeed: flickerSpeed));
    }
    return starList;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CelestialBackgroundPainter(_animationController, stars),
      child: Container(), // Empty container since we only need the custom paint
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
