import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/custom_button.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_category_model.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart';
import 'package:flutter_application_1/features/ask_a_question/repo/ask_a_question_repo.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/inbox/ui/inbox_page.dart';
import 'package:flutter_application_1/features/payment/ui/payment_page.dart';

class AskQuestion extends StatefulWidget {
  @override
  _AskQuestionPageState createState() => _AskQuestionPageState();
}

class _AskQuestionPageState extends State<AskQuestion> {
  String? selectedCategory;
  String? selectedQuestionId;
  List<QuestionCategory> categories = [];
  List<Question> questions = [];
  final AskQuestionRepository _askQuestionRepository = AskQuestionRepository();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categoryModels = await _askQuestionRepository.fetchCategories();
      setState(() {
        categories = categoryModels;
        selectedCategory = categories.isNotEmpty ? categories.first.id : null;
        if (selectedCategory != null) {
          _loadQuestions(selectedCategory!);
        }
      });
    } catch (e) {
      // Handle error
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadQuestions(String categoryId) async {
    try {
      final questionModels = await _askQuestionRepository.fetchQuestions(categoryId);
      setState(() {
        questions = questionModels;
        selectedQuestionId = questions.isNotEmpty ? questions.first.id : null;
      });
    } catch (e) {
      // Handle error
      print('Error loading questions: $e');
    }
  }

  void _updateQuestions(String categoryId) {
    _loadQuestions(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
    onWillPop: () async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
      return false; // Prevent the default back button behavior
    },
    child:Scaffold(
       backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
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
                      'Ask a Question',
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
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: Container(
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                decoration: ShapeDecoration(
                  shape: CircleBorder(
                    side: BorderSide(width: 1, color: Color(0xFFFF9933)),
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/questions.png',
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.18,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Select a category:',
                      style: TextStyle(
                        color: Color(0xFFFF9933),
                        fontSize: screenWidth * 0.045,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFFF9933), width: 1),
                      ),
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        underline: SizedBox(),
                        items: categories.map((QuestionCategory category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.category),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedCategory = newValue;
                              _updateQuestions(newValue);
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: Text(
                      'Select a question:',
                      style: TextStyle(
                        color: Color(0xFFFF9933),
                        fontSize: screenWidth * 0.045,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  if (questions.isNotEmpty)
                    Container(
                      height: screenHeight * 0.3,
                      child: ListView.builder(
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          final isSelected = selectedQuestionId == question.id;
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Color(0xFFFF9933) : Colors.black,
                                width: 1, // Adjust border width as needed
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text(
                                question.question,
                                style: TextStyle(
                                  color: isSelected ? Colors.orange : Colors.black,
                                  fontSize: screenWidth * 0.03
                                ),
                              ),
                              trailing: Text(
                                '\$${question.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isSelected ? Colors.orange : Color(0xFFFF9933),
                                  fontSize: screenWidth * 0.03
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedQuestionId = question.id;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Center(child: Text('No questions available')),
                ],
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
        ),
      )
    );
    
  }
}
