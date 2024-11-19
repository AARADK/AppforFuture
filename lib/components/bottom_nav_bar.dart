import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/ask_a_question/ui/ask_a_question_page.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/inbox/ui/inbox_page.dart';

class BottomNavBar extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final int? currentPageIndex;

  BottomNavBar({
    required this.screenWidth,
    required this.screenHeight,
    this.currentPageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CustomPaint(
          size: Size(screenWidth, screenHeight * 0.08),
          painter: _CurvedBorderPainter(),
        ),
        Positioned(
          bottom: screenHeight * 0.04, // Adjust height to fit inside the curve
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
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildNavItem(
                context,
                index: 0,
                iconImage: 'assets/images/horoscope2.png',
                label: 'Horoscope',
                targetPage: HoroscopePage(),
              ),
              _buildNavItem(
                context,
                index: 1,
                iconImage: 'assets/images/compatibility2.png',
                label: 'Compatibility',
                targetPage: CompatibilityPage(),
              ),
              SizedBox(width: screenWidth * 0.2),
              _buildNavItem(
                context,
                index: 2,
                iconImage: 'assets/images/auspicious2.png',
                label: 'Auspicious',
                targetPage: AuspiciousTimePage(),
              ),
              _buildNavItem(
                context,
                index: 3,
                iconImage: 'assets/images/Inbox.png',
                label: 'Inbox',
                targetPage: InboxPage(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    String? iconImage,
    IconData? icon,
    required String label,
    required Widget targetPage,
  }) {
    bool isSelected = currentPageIndex == index;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          iconImage != null
              ? Image.asset(
                  iconImage,
                  width: screenWidth * 0.07,
                  height: screenWidth * 0.07,
                  color: isSelected ? Color(0xFFFF9933) : null,
                )
              : Icon(
                  icon,
                  color: isSelected ? Color(0xFFFF9933) : Color.fromARGB(255, 5, 5, 5),
                  size: screenWidth * 0.07,
                ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Color(0xFFFF9933) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
class _CurvedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color(0xFFD3D3D3) // Very light gray color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Create the path for the curve (only the top border line)
    Path path = Path()
      ..moveTo(0, 0) // Start at the left edge
      ..lineTo(size.width * 0.4, 0) // Draw a straight line until 40% width
      ..arcTo(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, 0), // Center the curve horizontally
          radius: size.height * 0.6, // Radius of the curve
        ),
        3.14, // Start angle (pi, for half circle)
        -3.14, // Sweep angle (negative pi to curve downward)
        false,
      )
      ..lineTo(size.width, 0); // Continue a straight line to the right edge

    // Add a shadow only to the path (the line itself)
    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 4.0, false);

    // Draw the light gray path (the top border line itself)
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

  