import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/components/custom_button.dart';
import 'package:flutter_application_1/components/questionlistwidget.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart';
import 'package:flutter_application_1/features/ask_a_question/repo/ask_a_question_repo.dart';
import 'package:flutter_application_1/features/ask_a_question/ui/ask_a_question_page.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/inbox/ui/inbox_page.dart';
import 'package:flutter_application_1/features/partner/ui/partner_details_page.dart';
import 'package:flutter_application_1/features/payment/ui/payment_page.dart';
import 'package:flutter_application_1/features/profile/model/profile_model.dart';
import 'package:flutter_application_1/features/profile/repo/profile_repo.dart';
import 'package:flutter_application_1/features/profile/service/profile_services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompatibilityPage2 extends StatefulWidget {
  @override
  _CompatibilityPage2State createState() => _CompatibilityPage2State();
}

class _CompatibilityPage2State extends State<CompatibilityPage2> {
  final Color primaryColor = Color(0xFFFF9933);
  ProfileModel? _profile;
  Map<String, dynamic>? _compatibilityData;
  bool _isLoading = true;
  String? _errorMessage;
  String? _person2Name = 'Person 2'; // Variable to store Person 2's name
  late Future<List<Question>> _questionsFuture; // Future for Horoscope questions
  final AskQuestionRepository _askQuestionRepository = AskQuestionRepository(); // Instantiate the repository



  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _questionsFuture = _askQuestionRepository.fetchQuestionsByTypeId(2);

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
              padding: EdgeInsets.only(bottom: screenHeight * 0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Done',
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Inter',
                                color: primaryColor,
                              ),
                            ),
                          ),
                          Text(
                            'Compatibility',
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Inter',
                              color: primaryColor,
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
                                border: Border.all(color: primaryColor),
                                borderRadius: BorderRadius.circular(screenWidth * 0.06),
                              ),
                              child: Icon(Icons.inbox, color: primaryColor, size: screenWidth * 0.06),
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
                        'assets/images/virgo.png',
                        _profile?.name ?? 'Person 1', // Display name if available
                        screenWidth,
                        context,
                      ),
                      SizedBox(width: screenWidth * 0.1),
                      _buildCircleWithName(
                        'assets/images/pisces.png',
                        _person2Name!, // Display the entered name or "Person 2"
                        screenWidth,
                        context,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                          ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
                          : Padding(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _compatibilityData?.entries.map((entry) {
                                  return _buildCompatibilityRow(entry.key, entry.value);
                                }).toList() ?? [],
                              ),
                            ),
                            // SizedBox(height: screenHeight * 0.01),
                  QuestionListWidget(
        questionsFuture: _questionsFuture,
        title: 'Ideas what to ask:',
        onTapQuestion: _showQuestionDetails,
      ),
                ],
              ),
            ),
          ),
            CustomButton(
            buttonText: 'Submit',
            onPressed: () {
            // Define your button action
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentPage()),
            );
          },
            screenWidth: screenWidth,
            screenHeight: screenHeight,
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
            } else if (name == _person2Name) {
              _showEditableProfileDialog(context);
            } else {
              print("no name");
            }
          },
          child: Container(
            width: screenWidth * 0.25,
            height: screenWidth * 0.25,
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
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
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

  void _showEditableProfileDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController dobController = TextEditingController();
    final TextEditingController cityIdController = TextEditingController();
    final TextEditingController tobController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Person 2 Name'),
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
          TextButton(
            onPressed: () {
              setState(() {
                _person2Name = nameController.text.isEmpty
                    ? 'Person 2'
                    : nameController.text;
              });
              Navigator.of(context).pop();
            },
            child: Text('Save'),
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

  Widget _buildCompatibilityRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Text(value.toString(), style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildElevatedButton(BuildContext context, String label, Widget targetPage, double screenWidth, double screenHeight) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        minimumSize: Size(screenWidth * 0.8, screenHeight * 0.07),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNavBarIcon(BuildContext context, String assetPath, Widget targetPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage));
      },
      child: Image.asset(assetPath, width: 24, height: 24),
    );
  }
}

  /// Optional: Show question details in a dialog
  void _showQuestionDetails(BuildContext context, Question question) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Press the submit button if you are sure about this question.'),
          content: Text(question.question),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Add more actions if needed
          ],
        );
      },
    );
  }

