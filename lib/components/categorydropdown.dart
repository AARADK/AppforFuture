import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_category_model.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart';
import 'package:flutter_application_1/features/ask_a_question/service/ask_a_question_service.dart';
import 'package:flutter_application_1/features/profile/repo/profile_repo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart'; // Import Hive package

class CategoryDropdown extends StatefulWidget {
  final int categoryTypeId;
  final Function(String, List<Question>) onQuestionsFetched;
  final Map<String, dynamic>? editedProfile;
    final Map<String, dynamic>? editedProfile2;

  final String inquiryType; // Add the inquiry type (e.g., horoscope, auspicious time)
  final String? auspiciousFromDate; // Optional field for auspicious time inquiry

  const CategoryDropdown({
    required this.categoryTypeId,
    required this.onQuestionsFetched,
    this.editedProfile,
    this.editedProfile2,
    required this.inquiryType, // Accept inquiry type
    this.auspiciousFromDate, // Accept auspicious_from_date if needed

    Key? key,
  }) : super(key: key);

  

  @override
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final AskQuestionService _service = AskQuestionService();
  late Future<Map<int, List<QuestionCategory>>> _categoriesFuture;
  late Future<Map<String, List<Question>>> _questionsFuture;
  late Future<Map<String, dynamic>?> _profileFuture;
  String? selectedQuestionId;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories();
    _profileFuture = _fetchProfileData(); // Initialize the future for profile data
  }

  Future<Map<int, List<QuestionCategory>>> _fetchCategories() async {
    try {
      final allCategories = await _service.getCategories();
      final categoriesByType = <int, List<QuestionCategory>>{};

      for (var category in allCategories) {
        if (category.categoryTypeId == widget.categoryTypeId) {
          if (categoriesByType[category.categoryTypeId] == null) {
            categoriesByType[category.categoryTypeId] = [];
          }
          categoriesByType[category.categoryTypeId]!.add(category);
        }
      }

      return categoriesByType;
    } catch (e) {
      print('Error fetching categories: $e');
      return {};
    }
  }

  Future<Map<String, List<Question>>> _fetchQuestions(String categoryId) async {
    try {
      final questions = await _service.getQuestionsByTypeId(widget.categoryTypeId);
      final questionsByCategoryId = <String, List<Question>>{};

      for (var question in questions) {
        if (questionsByCategoryId[question.questionCategoryId] == null) {
          questionsByCategoryId[question.questionCategoryId] = [];
        }
        questionsByCategoryId[question.questionCategoryId]!.add(question);
      }

      widget.onQuestionsFetched(categoryId, questionsByCategoryId[categoryId] ?? []);
      return questionsByCategoryId;
    } catch (e) {
      print('Error fetching questions: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>?> _fetchProfileData() async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token');
      final url = 'http://52.66.24.172:7001/frontend/Guests/Get';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['error_code'] == "0") {
          return responseData['data']['item'];
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      return null;
    }
  }

  Future<void> _handleTickIconTap() async {
  if (selectedQuestionId == null) {
    print('No question selected');
    return;
  }

  try {
    final box = Hive.box('settings');
    String? token = await box.get('token');
    final url = 'http://52.66.24.172:7001/frontend/GuestInquiry/StartInquiryProcess';
    final profile = widget.editedProfile ?? await _profileFuture;
    
    if (profile == null) {
      print('Profile data not available');
      return;
    }
    
    // Build the initial body as a Map
    final body = {
      "inquiry_type": 0,
      "inquiry_regular": {
        "question_id": selectedQuestionId,
      },
      "profile1": {
        "name": profile['name'],
        "dob": profile['dob'],
        "city_id": profile['city_id'],
        "tob": profile['tob'],
      }
    };
    // If the inquiry is for compatibility, add profile2
    if (widget.inquiryType == 'compatibility' && widget.editedProfile2 != null) {
      body['profile2'] = {
        "name": widget.editedProfile2!['name'],
        "dob": widget.editedProfile2!['dob'],
        "city_id": widget.editedProfile2!['city_id'],
        "tob": widget.editedProfile2!['tob'],
      };
    }
    // If the inquiry is for auspicious time, add the "auspicious_from_date" field
    if (widget.inquiryType == 'auspicious_time' && widget.auspiciousFromDate != null) {
      body['auspicious_from_date'] = widget.auspiciousFromDate!;
    }

    // Convert body to JSON string
    final bodyJson = jsonEncode(body);

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: bodyJson,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Inquiry started successfully: $responseData');
    } else {
      print('Failed to start inquiry: ${response.statusCode}');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}


  void _showQuestions(BuildContext context, String categoryId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, List<Question>>>(
          future: _fetchQuestions(categoryId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching questions: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data![categoryId] == null || snapshot.data![categoryId]!.isEmpty) {
              return Center(child: Text('No questions available.'));
            } else {
              final questions = snapshot.data![categoryId]!;
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: questions.map((question) {
                            final isSelected = selectedQuestionId == question.id;
                            return ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(question.question)),
                                  Text(
                                    '\$${question.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              tileColor: isSelected ? Color(0xFFFF9933) : null,
                              trailing: isSelected
                                  ? IconButton(
                                      icon: Icon(Icons.check_circle, color: Colors.green),
                                      onPressed: _handleTickIconTap,
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<int, List<QuestionCategory>>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching categories: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data![widget.categoryTypeId] == null || snapshot.data![widget.categoryTypeId]!.isEmpty) {
          return Center(child: Text('No categories available.'));
        } else {
          final categories = snapshot.data![widget.categoryTypeId]!;
          return ExpansionTile(
            title: const Text('Ideas what to ask'),
            children: categories.map((category) {
              return ListTile(
                title: Text(category.category),
                onTap: () async {
                  await _fetchQuestions(category.id);
                  _showQuestions(context, category.id);
                },
              );
            }).toList(),
          );
        }
      },
    );
  }
}
