// category_dropdown.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_category_model.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart';
import 'package:flutter_application_1/features/ask_a_question/service/ask_a_question_service.dart';

class CategoryDropdown extends StatefulWidget {
  final int categoryTypeId;
  final Function(String, List<Question>) onQuestionsFetched;

  const CategoryDropdown({
    required this.categoryTypeId,
    required this.onQuestionsFetched,
    Key? key,
  }) : super(key: key);

  @override
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final AskQuestionService _service = AskQuestionService();
  Map<int, List<QuestionCategory>> categoriesByType = {};
  Map<String, List<Question>> questionsByCategoryId = {};

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
          if (category.categoryTypeId == widget.categoryTypeId) {
            if (categoriesByType[category.categoryTypeId] == null) {
              categoriesByType[category.categoryTypeId] = [];
            }
            categoriesByType[category.categoryTypeId]!.add(category);
          }
        }
      });
    } catch (e) {
      // Handle error
      print('Error fetching categories: $e');
    }
  }

  Future<void> _fetchQuestions(String categoryId) async {
    try {
      final questions = await _service.getQuestionsByTypeId(widget.categoryTypeId);
      setState(() {
        questionsByCategoryId = {};
        for (var question in questions) {
          if (questionsByCategoryId[question.questionCategoryId] == null) {
            questionsByCategoryId[question.questionCategoryId] = [];
          }
          questionsByCategoryId[question.questionCategoryId]!.add(question);
        }
      });
      widget.onQuestionsFetched(categoryId, questionsByCategoryId[categoryId] ?? []);
    } catch (e) {
      // Handle error
      print('Error fetching questions: $e');
    }
  }

  void _showQuestions(BuildContext context, String categoryId) {
    List<Question>? questions = questionsByCategoryId[categoryId];
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Ideas what to ask'),
      children: categoriesByType[widget.categoryTypeId]?.map((category) {
        return ListTile(
          title: Text(category.category),
          onTap: () async {
            await _fetchQuestions(category.id);
            _showQuestions(context, category.id);
          },
        );
      }).toList() ?? [],
    );
  }
}
