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
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white, // A clean white background for elegance
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Subtle shadow for depth
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -2), // Slight shadow at the top
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between the left and right sides
        crossAxisAlignment: CrossAxisAlignment.center, // Align all children at the center
        children: [
          // Left Side (First compartment)
          _buildNavItem(
            context,
            index: 0,
            iconImage: 'assets/images/horoscope2.png',
            label: 'Horoscope',
            targetPage: HoroscopePage(),
          ),
          // Right Side (Second compartment)
          _buildNavItem(
            context,
            index: 1,
            iconImage: 'assets/images/compatibility2.png',
            label: 'Compatibility',
            targetPage: CompatibilityPage(),
          ),
          // Third compartment (Ask button in the middle)
          _buildAskButton(context),
          // Fourth compartment
          _buildNavItem(
            context,
            index: 2,
            iconImage: 'assets/images/auspicious2.png',
            label: 'Auspicious',
            targetPage: AuspiciousTimePage(),
          ),
          // Fifth compartment
          _buildNavItem(
            context,
            index: 3,
            iconImage: 'assets/images/Inbox.png',
            label: 'Inbox',
            targetPage: InboxPage(),
          ),
        ],
      ),
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

    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        },
        behavior: HitTestBehavior.translucent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // Align the icon and text at the center
          children: [
            iconImage != null
                ? Image.asset(
                    iconImage,
                    width: screenWidth * 0.07,
                    height: screenWidth * 0.07,
                    color: isSelected
                        ? Color(0xFFFF9933)
                        : null, // Elegant color when selected
                  )
                : Icon(
                    icon,
                    color: isSelected
                        ? Color(0xFFFF9933)
                        : Color.fromARGB(255, 5, 5, 5),
                    size: screenWidth * 0.07,
                  ),
            SizedBox(height: 2), // Consistent spacing
            Text(
              label,
              style: TextStyle(
                fontSize: 10, // Slightly larger text for better legibility
                color: isSelected
                    ? Color(0xFFFF9933)
                    : Colors.black, // Consistent color change for selection
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal, // Bold when selected
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAskButton(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center, // Align button and text at the center
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AskQuestionPage()),
              );
            },
            child: Container(
              width: screenWidth * 0.070,
              height: screenWidth * 0.070,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF9933), // Elegant color for the button
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.3), // Soft shadow around the button
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                color: Colors.white, // White icon for contrast
                size: screenWidth * 0.06,
              ),
            ),
          ),
          SizedBox(height: 2), // Consistent spacing
          Text(
            'Ask',
            style: TextStyle(
              fontSize: 10, // Slightly larger text for better legibility
              color: Colors.black,
              fontWeight: FontWeight.normal, // Regular weight for the label
            ),
          ),
        ],
      ),
    );
  }
}