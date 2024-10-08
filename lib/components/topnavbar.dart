import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget {
  final String title;
  final VoidCallback onLeftButtonPressed;
  final IconData leftIcon;

  TopNavBar({
    required this.title,
    required this.onLeftButtonPressed,
    this.leftIcon = Icons.menu, // Default is menu, can change to 'done'
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double iconSize = size.width * 0.12;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          width: double.infinity, // Ensure it takes up full width
          child: Stack(
            children: [
              // Center the title
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Inter',
                    color: Color(0xFFFF9933),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Align the icon to the left and bottom
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: EdgeInsets.only(bottom: 8), // Add margin to match the bottom alignment
                  child: GestureDetector(
                    onTap: onLeftButtonPressed, // Call the action on button press
                    child: Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFFF9933)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(leftIcon, color: Color(0xFFFF9933)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
