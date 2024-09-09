import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart';
import 'package:flutter_application_1/features/ask_a_question/repo/ask_a_question_repo.dart';
import 'package:flutter_application_1/features/ask_a_question/ui/ask_a_question_page.dart';
import 'package:flutter_application_1/features/auspicious_time/model/auspicious_time_model.dart';
import 'package:flutter_application_1/features/auspicious_time/repo/auspicious_time_repo.dart';
import 'package:flutter_application_1/features/auspicious_time/service/auspicious_time_service.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/inbox/ui/inbox_page.dart';
import 'package:flutter_application_1/features/payment/ui/payment_page.dart';
import 'package:flutter_application_1/features/profile/model/profile_model.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;


class AuspiciousTimePage extends StatefulWidget {
  @override
  _AuspiciousPageState createState() => _AuspiciousPageState();
}

class _AuspiciousPageState extends State<AuspiciousTimePage> {
  final Color primaryColor = Color(0xFFFF9933);

  late Future<Auspicious> _auspiciousFuture;
  late Future<List<Question>> _questionsFuture; // Future for Horoscope questions
  final AskQuestionRepository _askQuestionRepository = AskQuestionRepository(); // Instantiate the repository
  final AuspiciousService _service = AuspiciousService(AuspiciousRepository());
   bool _isExpanded = false; // State variable for text expansion
  ProfileModel? _profile;
  Map<String, dynamic>? _auspiciousData;
  bool _isLoading = true;
  String? _errorMessage;
  // Add a DateTime variable to store the selected date
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Set the default date to the current date
    _fetchProfileData();
    _auspiciousFuture = _service.getAuspicious(_selectedDate!.toString().split(' ')[0]); // Initialize with the current date
    _questionsFuture = _askQuestionRepository.fetchQuestionsByTypeId(3);

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
            _auspiciousData = responseData['data']['horoscope'];
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
          _errorMessage = 'Failed to load horoscope data';
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

// Method to show the date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        // Fetch horoscope for the selected date
        _auspiciousFuture = _service.getAuspicious(picked.toString().split(' ')[0]); // Use the selected date
      });
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
                          'Auspicious Time',
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
                        'assets/images/virgo.png',
                        _profile?.name ?? 'no name avialable', // Display name if available
                        screenWidth,
                        context,
                      ),
                    ],
                  ),
                   SizedBox(height: screenHeight * 0.02),

                   // Add Date selector button
                  Center(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Select Date for Auspicious Time',
          style: TextStyle(
            color: Color(0xFFFF9933),
            fontSize: screenWidth * 0.04,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFFF9933)), // Border color
            borderRadius: BorderRadius.circular(8.0), // Rounded corners if desired
          ),
          child: TextButton(
            onPressed: () => _selectDate(context),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.01), // Padding inside the button
              child: Text(
                _selectedDate != null
                    ? '${_selectedDate!.toLocal()}'.split(' ')[0]
                    : 'YYYY-MM-DD',
                style: TextStyle(
                  color: Color(0xFFFF9933),
                  fontSize: screenWidth * 0.04,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),


                  SizedBox(height: screenHeight * 0.04),
                  // Horoscope Description
                FutureBuilder<Auspicious>(
                  future: _auspiciousFuture,
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
                    } else if (!snapshot.hasData || snapshot.data == null || snapshot.data?.description == null || snapshot.data!.description.isEmpty) {
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
                      final horoscope = snapshot.data!;
                      final description = horoscope.description;
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
                
               SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                      child: Text(
                        'Ideas what to ask :',
                        style: TextStyle(
                          color: Color(0xFFFF9933),
                          fontSize: screenWidth * 0.04,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  SizedBox(
                    height: screenHeight * 0.19, // Adjust the height based on how many questions you want visible
                    child: FutureBuilder<List<Question>>(
                      future: _questionsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                            child: Text(
                              'Error loading questions: ${snapshot.error}',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: screenWidth * 0.03,
                                fontFamily: 'Inter',
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                            child: Text(
                              'No related questions available.',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.03,
                                fontFamily: 'Inter',
                              ),
                            ),
                          );
                        } else {
                          final questions = snapshot.data!;
                          return ListView.builder(
                            itemCount: questions.length,
                            itemBuilder: (context, index) {
                              final question = questions[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.06,
                                  vertical: screenHeight * 0.005,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Color(0xFFFF9933)), // Orange border
                                    borderRadius: BorderRadius.circular(8), // Small rounded corners
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      question.question,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenWidth * 0.03,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    trailing: Text(
                                      '\$${question.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 20, 59, 17),
                                        fontSize: screenWidth * 0.03,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    onTap: () {
                                      _showQuestionDetails(context, question);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
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
                        MaterialPageRoute(builder: (context) => PaymentPage()),
                      );
                    },
                    child: Text(
                      'Submit',
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
          
            bottomNavigationBar: BottomNavBar(screenWidth: screenWidth, screenHeight: screenHeight,currentPageIndex: 2),

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