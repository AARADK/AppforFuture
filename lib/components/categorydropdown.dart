import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_category_model.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart';
import 'package:flutter_application_1/features/ask_a_question/service/ask_a_question_service.dart';
import 'package:flutter_application_1/features/auspicious_time/model/auspicious_time_model.dart';
import 'package:flutter_application_1/features/payment/ui/payment_page.dart';
import 'package:flutter_application_1/features/profile/repo/profile_repo.dart';
import 'package:flutter_application_1/hive/hive_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart'; // Import Hive package
import 'package:intl/intl.dart';  // Import intl package

class CategoryDropdown extends StatefulWidget {
  final int categoryTypeId;
  final Function(String, List<Question>) onQuestionsFetched;
  final Map<String, dynamic>? editedProfile;
  final Map<String, dynamic>? editedProfile2;

  final String
      inquiryType; // Add the inquiry type (e.g., horoscope, auspicious time)
  // final String? auspiciousFromDate;
  // final String? horoscopeFromDate; // Optional field for auspicious time inquiry
  // final VoidCallback onTap;
  

  const CategoryDropdown({
    // required this.onTap,
    required this.categoryTypeId,
    required this.onQuestionsFetched,
    this.editedProfile,
    this.editedProfile2,
    required this.inquiryType, // Accept inquiry type
    // this.auspiciousFromDate,
    // this.horoscopeFromDate, // Accept auspicious_from_date if needed

    Key? key,
  }) : super(key: key);

  @override
  CategoryDropdownState createState() => CategoryDropdownState();
}

class CategoryDropdownState extends State<CategoryDropdown> {
  final AskQuestionService _service = AskQuestionService();
  late Future<Map<int, List<QuestionCategory>>> _categoriesFuture;
  late Future<Map<String, List<Question>>> _questionsFuture;
  late Future<Map<String, dynamic>?> _profileFuture;
  String? selectedQuestionId;
   DateTime? selectedDate;

  // Variables for storing the selected date
  String? auspicious_from_date;
  String? horoscope_from_date;

// Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;
    
    setState(() {
      selectedDate = picked;
      print(selectedDate);
      print(picked);

       String? formattedPicked;
    if (picked != null) {
      formattedPicked = DateFormat('yyyy-MM-dd').format(picked!);  // Format to yyyy-MM-dd
    }
    print(formattedPicked);

      // Store the date in the appropriate variable based on the page type
      if (widget.inquiryType == 'auspicious_time') {
        auspicious_from_date = formattedPicked;
        print(auspicious_from_date);
      } else if (widget.inquiryType == 'Horoscope') {
        horoscope_from_date = formattedPicked;
        print(horoscope_from_date);

      }
    });
  }

  

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories();
     if (widget.categoryTypeId != 4) {
    _questionsFuture = _fetchQuestionsForType(widget.categoryTypeId);
  }
    _profileFuture =
        _fetchProfileData(); // Initialize the future for profile data
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
      final questions =
          await _service.getQuestionsByTypeId(widget.categoryTypeId);
      final questionsByCategoryId = <String, List<Question>>{};

      for (var question in questions) {
        if (questionsByCategoryId[question.questionCategoryId] == null) {
          questionsByCategoryId[question.questionCategoryId] = [];
        }
        questionsByCategoryId[question.questionCategoryId]!.add(question);
      }

      widget.onQuestionsFetched(
          categoryId, questionsByCategoryId[categoryId] ?? []);
      return questionsByCategoryId;
    } catch (e) {
      print('Error fetching questions: $e');
      return {};
    }
    
  }
  Future<Map<String, List<Question>>> _fetchQuestionsForType(int categoryTypeId) async {
  try {
    final questions = await _service.getQuestionsByTypeId(categoryTypeId);
    final questionsByCategoryId = <String, List<Question>>{};

    for (var question in questions) {
      if (questionsByCategoryId[question.questionCategoryId] == null) {
        questionsByCategoryId[question.questionCategoryId] = [];
      }
      questionsByCategoryId[question.questionCategoryId]!.add(question);
    }

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
      final url = 'http://145.223.23.200:3002/frontend/Guests/Get';

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

Future<void> handleTickIconTap() async {
  if (selectedQuestionId == null) {
    print('No question selected');
    return;
  }

  try {
    final box = Hive.box('settings');
    String? token = await box.get('token');
    final url = 'http://145.223.23.200:3002/frontend/GuestInquiry/StartInquiryProcess';
    final profile = widget.editedProfile ?? await _profileFuture;

    if (profile == null) {
      print('Profile data not available');
      return;
    }

    // // Format the dates to "yyyy-MM-dd" without time
    // String? formattedAuspiciousDate;
    // if (auspicious_from_date != null) {
    //   formattedAuspiciousDate = DateFormat('yyyy-MM-dd').format(auspicious_from_date!);  // Format to yyyy-MM-dd
    // }

    // String? formattedHoroscopeDate;
    // if (horoscope_from_date != null) {
    //   formattedHoroscopeDate = DateFormat('yyyy-MM-dd').format(horoscope_from_date!);  // Format to yyyy-MM-dd
    // }

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
    if (widget.inquiryType == 'auspicious_time' && auspicious_from_date != null) {
      body['auspicious_from_date'] = auspicious_from_date!;
    }

    // If the inquiry is for horoscope, add the "horoscope_from_date" field
    if (widget.inquiryType == 'Horoscope' && horoscope_from_date != null) {
      body['horoscope_from_date'] = horoscope_from_date!;
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
              if (inquiryNumber != null) Text('Inquiry Number: $inquiryNumber'),
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
        return FutureBuilder<Map<String, List<Question>>>(
          future: _fetchQuestions(categoryId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Error fetching questions: ${snapshot.error}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            } else if (!snapshot.hasData ||
                snapshot.data![categoryId] == null ||
                snapshot.data![categoryId]!.isEmpty) {
              return AlertDialog(
                title: Text('No questions available'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            } else {
              final questions = snapshot.data![categoryId]!;
              return AlertDialog(
                title: Text('Select a Question'),
                content: SizedBox(
                  width: 400, // Fixed width
                  height: 500, // Fixed height
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children: questions.map((question) {
                                final isSelected =
                                    selectedQuestionId == question.id;
                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Color(0xFFFF9933), width: 1.0),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  color: isSelected
                                      ? Color(0xFFFF9933)
                                      : Colors.white,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(8),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            question.question,
                                            style: TextStyle(
                                              fontSize: 12, // Smaller font size
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                        // Price display
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '\$${question.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize:
                                                    12, // Smaller font size
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.green,
                                              ),
                                            ),
                                            if (isSelected)
                                              Icon(Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 16),
                                          ],
                                        ),
                                      ],
                                    ),
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
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              SizedBox(width: 8), // Space between buttons
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  handleTickIconTap();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }
          },
        );
      },
    );
  }

 @override
Widget build(BuildContext context) {
  // Check if categoryTypeId is 2, use categoriesFuture; otherwise, use questionsFuture
  // if (widget.categoryTypeId == 4) {
  //   return FutureBuilder<Map<int, List<QuestionCategory>>>(
  //     future: _categoriesFuture,
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(child: CircularProgressIndicator());
  //       } else if (snapshot.hasError) {
  //         return Center(child: Text('Error fetching categories: ${snapshot.error}'));
  //       } else if (!snapshot.hasData ||
  //           snapshot.data![widget.categoryTypeId] == null ||
  //           snapshot.data![widget.categoryTypeId]!.isEmpty) {
  //         return Center(child: Text('No categories available.'));
  //       } else {
  //         final categories = snapshot.data![widget.categoryTypeId]!;
  //         return ExpansionTile(
  //           title: Container(
  //             decoration: BoxDecoration(
  //               border: Border.all(
  //                 color: Color(0xFFFF9933),
  //                 width: 2.0,
  //               ),
  //               borderRadius: BorderRadius.circular(5),
  //             ),
  //             child: SizedBox(
  //               height: 50,
  //               child: Row(
  //                 children: [
  //                   SizedBox(width: 10),
  //                   Expanded(
  //                     child: Text(
  //                       'Ideas what to ask',
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         color: Color(0xFFFF9933),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           children: categories.map((category) {
  //             return ListTile(
  //               title: Text(category.category),
  //               onTap: () async {
  //                 await _fetchQuestions(category.id);
  //                  _showQuestions(context, category.id);
  //               },
  //             );
  //           }).toList(),
  //         );
  //       }
  //     },
  //   );
  // } else {
    // Handle categoryTypeId not equal to 2 (display questions directly)
    return Center(
  child: FutureBuilder<Map<String, List<Question>>>(
    future: _questionsFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text(
          'Error fetching questions: ${snapshot.error}',
          style: TextStyle(color: Colors.red),
        );
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Text(
          'No questions available.',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        );
      } else {
        final questions = snapshot.data!.values.expand((list) => list).toList();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 25), // Padding on left and right
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 0.5), // Further reduced margin
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0, // Divider between items
                    ),
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4), // Reduced padding
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          question.question,
                          style: TextStyle(fontSize: 14), // Smaller text
                        ),
                      ),
                      Text(
                        '\$${question.price}', // Display price
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9933), // Price in orange color
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() async {
                      selectedQuestionId = question.id;
                       await _selectDate(context);
                       // Then navigate to the payment page
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                       builder: (context) => PaymentPage(handleTickIconTap: handleTickIconTap)
                ));});
                  },
                ),
              );
            },
          ),
        );
      }
    },
  ),
);
}
}
