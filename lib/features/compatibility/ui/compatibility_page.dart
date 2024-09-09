import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/features/ask_a_question/ui/ask_a_question_page.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/model/compatibility_model.dart';
import 'package:flutter_application_1/features/compatibility/service/compatibility_service.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page2.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/inbox/ui/inbox_page.dart';
import 'package:flutter_application_1/features/payment/ui/payment_page.dart';
import 'package:flutter_application_1/features/compatibility/repo/compatibility_repo.dart';
import 'package:flutter_application_1/features/profile/model/profile_model.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;


class CompatibilityPage extends StatefulWidget {
  @override
  _CompatibilityPageState createState() => _CompatibilityPageState();
}

class _CompatibilityPageState extends State<CompatibilityPage> {
  late Future<Compatibility> _compatibilityFuture;
  final CompatibilityService _service = CompatibilityService(CompatibilityRepository());
  final Color primaryColor = Color(0xFFFF9933);
  ProfileModel? _profile;
  Map<String, dynamic>? _compatibilityData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isExpanded = false; // State variable for text expansion


  @override
  void initState() {
    super.initState();
        _fetchProfileData();

    // Get the current date
    final today = DateTime.now();
    final formattedDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    _compatibilityFuture = _service.getCompatibility(formattedDate); // Use dynamic date if needed
  }

  Future<void> _fetchProfileData() async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token');
      String url = 'http://52.66.24.172:7001/frontend/Guests/Get';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['error_code'] == "0") {
          setState(() {
            _profile = ProfileModel.fromJson(responseData['data']['item']);
            _compatibilityData = responseData['data']['compatibility'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = responseData['message'];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load compatibility data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    backgroundColor: Colors.white,
    body: Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.4), // Increased bottom padding to accommodate questions
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DashboardPage()),
                            );
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
                          'Compatibility',
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
                SizedBox(height: screenHeight * 0.05),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCircleWithName(
                        'assets/images/compatibility2.png',
                        _profile?.name ?? 'no name avialable', // Display name if available
                        screenWidth,
                        context,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  // Horoscope Description
                FutureBuilder<Compatibility>(
                  future: _compatibilityFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Data is being generated, please wait....',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.040,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w100,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data == null || snapshot.data?.compatibility == null || snapshot.data!.compatibility.isEmpty) {
                      return Center(
                        child: Text(
                          'No horoscope data available at the moment.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.040,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w100,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      final compatibility = snapshot.data!;
                      final description = compatibility.compatibility;
                      final maxLines = _isExpanded ? null : 3; // Show full text if expanded, else limit to 3 lines

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              description,
                              maxLines: maxLines,
                              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.040,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isExpanded = !_isExpanded; // Toggle text expansion
                                });
                              },
                              child: Text(
                                _isExpanded ? 'View Less' : 'View More', // Change button text based on state
                                style: TextStyle(
                                  color: Color(0xFFFF9933),
                                  fontSize: screenWidth * 0.03,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                  
                ],
              ),
            ),
          ),
      
           Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: screenHeight * 0.01),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CompatibilityPage2()),
                      );
                    },
                    child: Text(
                      'Get specific compatibility',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
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
                ],
              ),
            ),
          ),
        ],
      ),
          
            bottomNavigationBar: BottomNavBar(screenWidth: screenWidth, screenHeight: screenHeight,currentPageIndex: 0),

  );
}

Widget _buildCircleWithName(String assetPath, String name, double screenWidth, BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (name == _profile?.name && _profile != null) {
              _showProfileDialog(context, _profile!);
            } else {
              print("no name");
            }
          },
          child: Container(
            width: screenWidth * 0.3,
            height: screenWidth * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor,
                width: 2,
              ),
            ),
            child: Center(
              child: Image.asset(
                assetPath,
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        Text(name, style: TextStyle(fontSize: screenWidth * 0.04, color: primaryColor)),
      ],
    );
  }

  void _showProfileDialog(BuildContext context, ProfileModel profile) {
    final TextEditingController nameController = TextEditingController(text: profile.name);
    final TextEditingController dobController = TextEditingController(text: profile.dob);
    final TextEditingController cityIdController = TextEditingController(text: profile.cityId);
    final TextEditingController tobController = TextEditingController(text: profile.tob);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Name', nameController),
            _buildTextField('Date of Birth', dobController),
            _buildTextField('Place of Birth', cityIdController),
            _buildTextField('Time of Birth', tobController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 5),
        TextField(controller: controller),
      ],
    );
  }
}