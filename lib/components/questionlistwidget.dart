import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_category_model.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart';
import 'package:flutter_application_1/features/ask_a_question/service/ask_a_question_service.dart';

class QuestionListWidget extends StatefulWidget {
  final int categoryTypeId;
  final String title;

  const QuestionListWidget({
    required this.categoryTypeId,
    required this.title,
  });

  @override
  _QuestionListWidgetState createState() => _QuestionListWidgetState();
}

class _QuestionListWidgetState extends State<QuestionListWidget> {
  final AskQuestionService _service = AskQuestionService();
  List<QuestionCategory> categories = [];
  Map<String, List<Question>> questionsByCategoryId = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final allCategories = await _service.getCategoriesByTypeId(widget.categoryTypeId);
      setState(() {
        categories = allCategories;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchQuestions(String categoryId) async {
    try {
      final questions = await _service.getQuestions(categoryId);
      setState(() {
        questionsByCategoryId[categoryId] = questions;
      });
    } catch (e) {
      print('Error fetching questions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenHeight * 0.01),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Text(
              widget.title,
              style: TextStyle(
                color: Color(0xFFFF9933),
                fontSize: screenWidth * 0.04,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.005),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : Expanded(
                child: ListView(
                  children: categories.map((category) {
                    return ListTile(
                      title: Text(category.category),
                      onTap: () async {
                        await _fetchQuestions(category.id);
                        _showQuestions(context, category.id);
                      },
                    );
                  }).toList(),
                ),
              ),
        SizedBox(height: screenHeight * 0.08),
      ],
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
