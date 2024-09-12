import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/components/custom_button.dart';
import 'package:flutter_application_1/components/topnavbar.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_category_model.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart';
import 'package:flutter_application_1/features/ask_a_question/service/ask_a_question_service.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/payment/ui/payment_page.dart';

class AskQuestionPage extends StatefulWidget {
  @override
  _AskQuestionPageState createState() => _AskQuestionPageState();
}

class _AskQuestionPageState extends State<AskQuestionPage> {
  final AskQuestionService _service = AskQuestionService();
  Map<int, List<QuestionCategory>> categoriesByType = {};
  Map<String, List<Question>> questionsByCategoryId = {};
  int? selectedTypeId;

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
                    title: 'Auspicious Time',
                    onLeftButtonPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DashboardPage()),
                      );
                    },
                    leftIcon: Icons.done,
                  ),

          // Main body with category and questions list
          Expanded(
            child: ListView(
              children: categoriesByType.entries.map((entry) {
                int typeId = entry.key;
                List<QuestionCategory> categories = entry.value;

                return ExpansionTile(
                  title: Text('Category Type ID: $typeId'),
                  children: categories.map((category) {
                    return ListTile(
                      title: Text(category.category),
                      onTap: () async {
                        setState(() {
                          selectedTypeId = typeId;
                        });
                        await _fetchQuestions(typeId);
                        _showQuestions(context, category.id);
                      },
                    );
                  }).toList(),
                );
              }).toList(),
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
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        List<Question>? questions = questionsByCategoryId[categoryId];

        if (questions == null || questions.isEmpty) {
          return Center(child: Text('No questions available.'));
        }

        return ListView(
          children: questions.map((question) {
            return ListTile(
              title: Text(question.question),
              trailing: Text('\$${question.price.toStringAsFixed(2)}'),
            );
          }).toList(),
        );
      },
    );
  }
}
