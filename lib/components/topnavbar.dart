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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
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
             // Use Expanded to center the text in the middle
            Expanded(
              child: Center(
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
            ),
           
          ],
        ),
      ),
    );
  }
}
