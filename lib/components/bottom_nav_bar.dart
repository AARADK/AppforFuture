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
        border: Border(top: BorderSide(color: Color(0xFFFF9933), width: 2)),
      ),
      padding: EdgeInsets.symmetric(
        // vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.05,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end, // Align all children at the bottom
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
        mainAxisAlignment: MainAxisAlignment.end, // Align the icon and text at the bottom
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFFF9933).withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: iconImage != null
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
          ),
          SizedBox(height: 2), // Consistent spacing
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

  Widget _buildAskButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end, // Align button and text at the bottom
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AskQuestionPage()),
            );
          },
          child: Container(
            width: screenWidth * 0.09,
            height: screenWidth * 0.09,
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
              size: screenWidth * 0.06,
            ),
          ),
        ),
        SizedBox(height: 2), // Consistent spacing
        Text(
          'Ask',
          style: TextStyle(
            fontSize: 10,
            color: const Color.fromARGB(255, 2, 2, 2),
          ),
        ),
      ],
    );
  }
}
