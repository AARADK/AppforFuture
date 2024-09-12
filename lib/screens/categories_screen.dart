import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';
import '../services/api_service.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  List<Question> _questions = [];
  String selectedCategoryId = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      List<Category> categories = await _apiService.getCategories(1); // Type ID 1 (Horoscope)
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchQuestions(String categoryId) async {
    try {
      List<Question> questions = await _apiService.getQuestions(categoryId);
      setState(() {
        _questions = questions;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories')),
      body: Column(
        children: [
          // Categories List
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ListTile(
                  title: Text(category.category),
                  onTap: () {
                    setState(() {
                      selectedCategoryId = category.id;
                    });
                    fetchQuestions(category.id);
                  },
                );
              },
            ),
          ),
          Divider(),
          // Questions List (Only if a category is selected)
          selectedCategoryId.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      return ListTile(
                        title: Text(question.question),
                        subtitle: Text('Price: ${question.price}'),
                      );
                    },
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
