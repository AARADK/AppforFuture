import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/ask_a_question/ui/ask_a_question_page.dart';

class AskQuestionButton extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const AskQuestionButton({
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: screenHeight * 0.0, // Position from the bottom
          left: (screenWidth / 2) - (screenWidth * 0.075), // Center horizontally
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AskQuestionPage()),
              );
            },
            child: Container(
              width: screenWidth * 0.15,
              height: screenWidth * 0.15,
              decoration: BoxDecoration(
                color: Color(0xFFFF9933),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: screenWidth * 0.08, // Adjust icon size to fit in the circle
              ),
            ),
          ),
        ),
      ],
    );
  }
}
