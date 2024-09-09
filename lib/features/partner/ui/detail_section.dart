import 'package:flutter/material.dart';

class DetailSection extends StatelessWidget {
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final Function? onTap;
  final TextEditingController controller;

  DetailSection({
    required this.label,
    required this.hintText,
    required this.keyboardType,
    this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 70,
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFFF9933),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 50,
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      borderSide: BorderSide(color: Color(0xFFFF9933), width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      borderSide: BorderSide(color: Color(0xFFFF9933), width: 2.0),
                    ),
                    hintText: hintText,
                    hintStyle: TextStyle(color: Colors.white70, fontFamily: 'Inter'),
                  ),
                  keyboardType: keyboardType,
                  style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
                  readOnly: onTap != null,
                  onTap: onTap != null ? () => onTap!() : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
