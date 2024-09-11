// lib/ui/inbox_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/components/topnavbar.dart';
import 'package:flutter_application_1/features/ask_a_question/ui/ask_a_question_page.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page2.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/inbox/model/inbox_model.dart';
import 'package:flutter_application_1/features/inbox/service/inbox_service.dart';
import 'package:flutter_application_1/features/inbox/ui/chat_box_page.dart';

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final MessageService _messageService = MessageService();
  late List<Message> _messages;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _messages = _messageService.fetchMessages();
  }

  void _openChatBox(Message message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatBoxPage(message: message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Message> filteredMessages = _messages.where((message) {
      return message.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             message.content.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
       backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Using TopNavWidget instead of SafeArea with custom AppBar
                    // Use TopNavBar here with correct arguments
                    TopNavBar(
                      title: 'Inbox',
                      onLeftButtonPressed: () {
                        Navigator.pop(
                          context,
                          
                        );
                      },
                      leftIcon: Icons.arrow_back, // Optional: Change to menu if you want
                    ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Color(0xFFC06500)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredMessages.length,
              itemBuilder: (context, index) {
                final message = filteredMessages[index];
                return ListTile(
                  leading: Container(
                    width: screenWidth * 0.08,
                    height: screenHeight * 0.04,
                    decoration: BoxDecoration(
                      color: message.categoryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    message.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.normal,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                  subtitle: Text(
                    message.content,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                  onTap: () => _openChatBox(message),
                );
              },
            ),
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
             bottomNavigationBar: BottomNavBar(screenWidth: screenWidth, screenHeight: screenHeight,currentPageIndex: 3),

  );
  }
}