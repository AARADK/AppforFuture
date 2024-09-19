import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_category_model.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart';
import 'package:flutter_application_1/features/ask_a_question/service/ask_a_question_service.dart';
import 'package:flutter_application_1/features/profile/repo/profile_repo.dart';
import 'package:flutter_application_1/hive/hive_service.dart';
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

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (responseData['error_code'] == "0") {
        // Save the inquiry number in Hive
        String inquiryNumber = responseData['data']['inquiry_number'];
        await HiveService().saveInquiryNumber(inquiryNumber);

        // Show success message if error_code is 0
        _showResultDialog(responseData['message'], inquiryNumber);
      } else if (responseData['error_code'] == "1") {
        // Show error message if error_code is 1
        _showErrorDialog(responseData['message']);
      }
    } else {
      print('Failed to start inquiry: ${response.statusCode}');
      _showErrorDialog('Failed to start inquiry. Please try again later.');
    }
  } catch (e) {
    print('An error occurred: $e');
    _showErrorDialog('An error occurred. Please try again later.');
  }
}
  void _showResultDialog(String message, String? inquiryNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (inquiryNumber != null) 
                Text('Inquiry Number: $inquiryNumber'),
                
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sorry!'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showQuestions(BuildContext context, String categoryId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final screenSize = MediaQuery.of(context).size;
      final screenWidth = screenSize.width;
      final screenHeight = screenSize.height;

      final double fontSizeTitle = screenWidth * 0.05;
      final double fontSizeSubtitle = screenWidth * 0.04;
      final double padding = screenWidth * 0.03;
      final double buttonFontSize = screenWidth * 0.04;

      return FutureBuilder<Map<String, List<Question>>>(
        future: _fetchQuestions(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: Text('Error', style: TextStyle(fontSize: fontSizeTitle)),
              content: Text('Error fetching questions: ${snapshot.error}', style: TextStyle(fontSize: fontSizeSubtitle)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK', style: TextStyle(fontSize: buttonFontSize)),
                ),
              ],
              backgroundColor: Colors.white,
            );
          } else if (!snapshot.hasData || snapshot.data![categoryId] == null || snapshot.data![categoryId]!.isEmpty) {
            return AlertDialog(
              title: Text('No questions available', style: TextStyle(fontSize: fontSizeTitle)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK', style: TextStyle(fontSize: buttonFontSize)),
                ),
              ],
              backgroundColor: Colors.white,
            );
          } else {
            final questions = snapshot.data![categoryId]!;
            return AlertDialog(
              title: Text('Select a Question', style: TextStyle(fontSize: fontSizeTitle)),
              content: SizedBox(
                width: screenWidth * 0.9,
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            children: questions.map((question) {
                              final isSelected = selectedQuestionId == question.id;
                             return Card(
  elevation: 2,
  margin: EdgeInsets.symmetric(vertical: padding / 2),
  shape: RoundedRectangleBorder(
    side: BorderSide(color: Color(0xFFFF9933), width: 1.0), // Border color and width
    borderRadius: BorderRadius.circular(4.0), // Rounded corners
  ),
  color: isSelected ? Color(0xFFFF9933) : Colors.white, // Card background color
  child: ListTile(
    contentPadding: EdgeInsets.all(padding),
    title: Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align text at the top
      children: [
        Expanded(
          child: Text(
            question.question,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w300,
            ),
            overflow: TextOverflow.visible, // Allow text to be visible
          ),
        ),
      ],
    ),
    subtitle: Row(
      children: [
        Text(
          '\$${question.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.green,
          ),
        ),
        if (isSelected) // Show the tick icon only if selected
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(Icons.check_circle, color: Colors.green, size: screenWidth * 0.05),
          ),
      ],
    ),
    tileColor: isSelected ? Color(0xFFFF9933) : null, // Color when selected
    onTap: () {
      setState(() {
        selectedQuestionId = question.id;
      });
    },
  ),
);



                            }).toList(),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('Cancel', style: TextStyle(fontSize: buttonFontSize)),
                            ),
                            SizedBox(width: padding), // Space between buttons
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                                _handleTickIconTap(); // Call the handle function
                              },
                              child: Text('OK', style: TextStyle(fontSize: buttonFontSize)),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              backgroundColor: Colors.white,
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
  title: Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: Color(0xFFFF9933), // Rectangle border color: ff9933
        width: 2.0, // Border width
      ),
      borderRadius: BorderRadius.circular(5), // Optional: to round the corners of the rectangle
    ),
    child: SizedBox(
      height: 50, // Adjust height to add space at the top and bottom
      child: Row(
        children: [
          SizedBox(width: 10), // Adds spacing from the left edge of the rectangle
          Expanded(
            child: Text(
              'Ideas what to ask',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9933), // Text color: ff9933
              ),
            ),
          ),
        ],
      ),
    ),
  ),
  children: categories.map((category) {
    return ListTile(
      title: Text(category.category),
      onTap: () async {
        await _fetchQuestions(category.id);
        _showQuestions(context, category.id);
      },
    );
  }).toList(),
)
;

        }
      },
    );
  }
}
