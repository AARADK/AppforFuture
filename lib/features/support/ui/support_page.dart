import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/inbox/ui/inbox_page.dart';
import 'package:flutter_application_1/features/support/model/support_model.dart';
import 'package:flutter_application_1/features/support/service/support_service.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page2.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/support/ui/support_submit.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    String feedback = _feedbackController.text;
    final supportService = SupportService();
    supportService.submitFeedback(FeedbackModel(feedback: feedback));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SupportSubmit(feedback: feedback)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Inter',
                              color: Color(0xFFFF9933),
                            ),
                          ),
                        ),
                        Text(
                          'Support',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Inter',
                            color: Color(0xFFFF9933),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => InboxPage()),
                            );
                          },
                          child: Container(
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFFFF9933)),
                              borderRadius: BorderRadius.circular(screenWidth * 0.06),
                            ),
                            child: Icon(Icons.inbox, color: Color(0xFFFF9933), size: screenWidth * 0.06),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Center(
                  child: Image.asset(
                    'assets/images/support.png',
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.3,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: TextField(
                    controller: _feedbackController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Enter your feedback or issues here...',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.15),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              color: Colors.white,
              child: Center(
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                 style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF9933),
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      fixedSize: Size(screenWidth * 0.6, screenHeight * 0.05),
                      shadowColor: Colors.black,
                      elevation: 10,
                    ),
                  ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(screenWidth: screenWidth, screenHeight: screenHeight),
    );
  }
}