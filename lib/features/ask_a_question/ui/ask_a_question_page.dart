import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_category_model.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart';
import 'package:flutter_application_1/features/ask_a_question/service/ask_a_question_service.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Ask a Question'),
      ),
      body: ListView(
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
