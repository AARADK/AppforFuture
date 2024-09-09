// lib/features/our_astrologers/ui/our_astrologers_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/astrologers/model/astrologer_model.dart';
import 'package:flutter_application_1/features/astrologers/repo/astrologer_repo.dart';
import 'package:flutter_application_1/features/astrologers/service/astrologer_service.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page2.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/inbox/ui/inbox_page.dart';

class OurAstrologersPage extends StatefulWidget {
  @override
  _OurAstrologersPageState createState() => _OurAstrologersPageState();
}

class _OurAstrologersPageState extends State<OurAstrologersPage> {
  final AstrologerService _astrologerService = AstrologerService(AstrologerRepository());
  late Future<List<Astrologer>> _astrologersFuture;

  @override
  void initState() {
    super.initState();
    _astrologersFuture = _astrologerService.getAstrologers();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
       backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Navigate back to previous screen
                        },
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
                        'Our Astrologers',
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
                            borderRadius: BorderRadius.circular(screenWidth * 0.06), // Matching radius
                          ),
                          child: Icon(Icons.inbox, color: Color(0xFFFF9933), size: screenWidth * 0.06),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: Image.asset(
                  'assets/images/astrologer.png', // Replace with your actual image asset path
                  width: screenWidth * 0.9, // Adjust width and height based on screen width
                  height: screenWidth * 0.7,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              FutureBuilder<List<Astrologer>>(
                future: _astrologersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    return Column(
                      children: snapshot.data!.map((astrologer) {
                        return Card(
                          child: ListTile(
                            leading: Image.asset(astrologer.imageUrl, width: 50, height: 50),
                            title: Text(astrologer.name),
                            subtitle: Text(astrologer.specialization),
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return Center(child: Text('No Astrologers found.'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFFF9933))),
        ),
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025, horizontal: screenWidth * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CompatibilityPage()),
                );
              },
              child: Image.asset(
                'assets/images/compatibility2.png',
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HoroscopePage()),
                );
              },
              child: Image.asset(
                'assets/images/horoscope2.png',
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuspiciousTimePage()),
                );
              },
              child: Image.asset(
                'assets/images/auspicious2.png',
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
