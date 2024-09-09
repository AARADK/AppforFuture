// lib/ui/chat_box_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/inbox/model/inbox_model.dart';

class ChatBoxPage extends StatelessWidget {
  final Message message;

  const ChatBoxPage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          message.title,
          style: TextStyle(
            color: Color(0xFFFF9933),
            fontFamily: 'Inter',
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFFFF9933)),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          message.content,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}