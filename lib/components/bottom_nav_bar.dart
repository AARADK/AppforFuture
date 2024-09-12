import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/ask_a_question/ui/ask_a_question_page.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/inbox/ui/inbox_page.dart';

class BottomNavBar extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final int? currentPageIndex; // Nullable, default to null

  BottomNavBar({
    required this.screenWidth,
    required this.screenHeight,
    this.currentPageIndex, // No requirement to pass this
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFFF9933), width: 2)), // Keep border same
      ),
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01, // Adjusted padding to ensure border stays the same
        horizontal: screenWidth * 0.05,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            context,
            index: 0,
            iconImage: 'assets/images/compatibility2.png',
            label: 'Compatibility',
            targetPage: CompatibilityPage(),
          ),
          _buildNavItem(
            context,
            index: 1,
            iconImage: 'assets/images/horoscope2.png',
            label: 'Horoscope',
            targetPage: HoroscopePage(),
          ),
          _buildAskButton(context),
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
            icon: Icons.mail,
            label: 'Inbox',
            targetPage: InboxPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {
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
    behavior: HitTestBehavior.translucent, // Ensures the entire area can be tapped
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(screenWidth * 0.02), // Increase the tappable area
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFFF9933).withOpacity(0.2) : Colors.transparent, // Optional feedback
            shape: BoxShape.circle, // Ensure the padding follows a circular area
          ),
          child: iconImage != null
              ? Image.asset(
                  iconImage,
                  width: screenWidth * 0.07, // Icon size remains small
                  height: screenWidth * 0.07, // Icon size remains small
                  color: isSelected ? Color(0xFFFF9933) : null,
                )
              : Icon(
                  icon,
                  color: isSelected ? Color(0xFFFF9933) : Color.fromARGB(255, 5, 5, 5),
                  size: screenWidth * 0.07, // Icon size remains small
                ),
        ),
        SizedBox(height: 2), // Reduced spacing between icon and text
        Text(
          label,
          style: TextStyle(
            fontSize: 10, // Smaller text size
            color: isSelected ? Color(0xFFFF9933) : Colors.black,
          ),
        ),
        SizedBox(height: 1), // Added a small space below the text
      ],
    ),
  );
}


  Widget _buildAskButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AskQuestionPage()),
            );
          },
          child: Container(
            width: screenWidth * 0.09, // Smaller button size
            height: screenWidth * 0.09, // Smaller button size
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromARGB(255, 2, 2, 2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.add,
              color: Color(0xFFFF9933),
              size: screenWidth * 0.06, // Smaller icon size
            ),
          ),
        ),
        SizedBox(height: 2), // Reduced spacing between button and text
        Text('Ask', style: TextStyle(fontSize: 10, color: const Color.fromARGB(255, 2, 2, 2))),
      ],
    );
  }
}
