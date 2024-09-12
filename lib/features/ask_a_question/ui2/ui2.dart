// categories_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/ask_a_question/model2/model2.dart';
import 'package:flutter_application_1/features/ask_a_question/service2/service2.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late Future<List<QuestionCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = AskQuestionService().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: FutureBuilder<List<QuestionCategory>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No categories available'));
          } else {
            final categories = snapshot.data!;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category.category),
                  onTap: () {
                    // Handle navigation to sub-categories or questions
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
