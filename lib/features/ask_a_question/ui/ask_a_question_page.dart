import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/components/categorydropdown.dart';
import 'package:flutter_application_1/components/custom_button.dart';
import 'package:flutter_application_1/components/topnavbar.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_category_model.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart';
import 'package:flutter_application_1/features/ask_a_question/service/ask_a_question_service.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/payment/ui/payment_page.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;


class AskQuestionPage extends StatefulWidget {
  @override
  _AskQuestionPageState createState() => _AskQuestionPageState();
}

class _AskQuestionPageState extends State<AskQuestionPage> {
  final AskQuestionService _service = AskQuestionService();
  Map<int, List<QuestionCategory>> categoriesByType = {};
  Map<String, List<Question>> questionsByCategoryId = {};
  int? selectedTypeId;
  String? selectedQuestionId;
   bool _isLoading = true;

  Map<String, dynamic> profile = {
    "name": "Ramesh", // Default user details
    "city_id": "Birjung",
    "dob": "2024-01-01",
    "tob": "11:10",
  };

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final allCategories = await _service.getCategories();
      setState(() {
        categoriesByType = {};
        for (var category in allCategories) {
          if (categoriesByType[category.categoryTypeId] == null) {
            categoriesByType[category.categoryTypeId] = [];
          }
          categoriesByType[category.categoryTypeId]!.add(category);
        }
      });
    } catch (e) {
      // Handle error
      print('Error fetching categories: $e');
    }
  }

  Future<void> _fetchQuestions(int typeId) async {
    try {
      final questions = await _service.getQuestionsByTypeId(typeId);
      setState(() {
        questionsByCategoryId = {};
        for (var question in questions) {
          if (questionsByCategoryId[question.questionCategoryId] == null) {
            questionsByCategoryId[question.questionCategoryId] = [];
          }
          questionsByCategoryId[question.questionCategoryId]!.add(question);
        }
      });
    } catch (e) {
      // Handle error
      print('Error fetching questions: $e');
    }
  }
  Future<void> _handleTickIconTap() async {
    if (selectedQuestionId == null) {
      print('No question selected');
      return;
    }

    try {
      final box = Hive.box('settings');
      String? token = await box.get('token'); // Retrieve the token from Hive storage

      final url = 'http://45.117.153.217:3001/frontend/GuestInquiry/StartInquiryProcess'; // Use your API URL
      final body = jsonEncode({
        "inquiry_type": 0,
        "inquiry_regular": {
          "question_id": selectedQuestionId,
        },
        "profile1": profile,
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the token in the request headers
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Handle success
        final responseData = jsonDecode(response.body);
        print('Inquiry started successfully: $responseData');
      } else {
        // Handle error
        print('Failed to start inquiry: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
    onWillPop: () async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
      return false;
    }, 
    child:Scaffold(
    backgroundColor: Colors.white,

      body: Column(
        children: [
         TopNavBar(
                    title: 'Ask a Question',
                    onLeftButtonPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DashboardPage()),
                      );
                    },
                    leftIcon: Icons.done,
                  ),
              SizedBox(height: screenHeight * 0.02),
Center(
  child: CategoryDropdown(
    
    inquiryType: 'ask_a_question',
    categoryTypeId: 5,
    onQuestionsFetched: (categoryId, questions) {
      // Handle the fetched questions here
    },
  ),
),

          // Custom button placed just after the content
          CustomButton(
            buttonText: 'Submit',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentPage()),
              );
            },
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),
          // Bottom navigation bar at the footer
        ],
      ),
          bottomNavigationBar: BottomNavBar(screenWidth: screenWidth, screenHeight: screenHeight),
    )
    );
  }


 void _showQuestions(BuildContext context, String categoryId) {
  List<Question>? questions = questionsByCategoryId[categoryId];
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      if (questions == null || questions.isEmpty) {
        return Center(child: Text('No questions available.'));
      }

      return Column(
        children: [
          Expanded(
            child: ListView(
              children: questions.map((question) {
                final isSelected = selectedQuestionId == question.id;
                return ListTile(
                  title: Text(question.question),
                  trailing: isSelected
                      ? IconButton(
                          icon: Icon(Icons.check_circle, color: Colors.green),
                          onPressed: _handleTickIconTap, // Handle tick icon tap
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      selectedQuestionId = question.id;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: _handleTickIconTap,
            child: Text('Submit'),
          ),
        ],
      );
    },
  );
}
}