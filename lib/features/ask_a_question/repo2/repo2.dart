import 'dart:convert';
import 'package:flutter_application_1/features/ask_a_question/model2/model2.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart'; // Ensure Hive is set up for secure storage

class AskQuestionRepository {
  final String categoryUrl = 'https://52.66.24.172:7001/frontend/GuestQuestion/GetQuestionCategory'; // Replace with your actual base URL
  final String questionUrl = 'http://52.66.24.172:7001/frontend/GuestQuestion/GetQuestion';

  

  Future<List<QuestionCategory>> fetchCategories() async {
   try {
      final box = Hive.box('settings');
      String? token = await box.get('token'); // Retrieve the token from Hive storage

      final response = await http.get(
        Uri.parse(categoryUrl),
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the request headers
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = (data['data']['question_category'] as List)
            .map((json) => QuestionCategory.fromJson(json))
            .toList();
        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<List<Question>> fetchQuestions({String? categoryId, int? typeId}) async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token'); // Retrieve the token from Hive storage

      final uri = Uri.parse(questionUrl)
          .replace(queryParameters: {
        if (categoryId != null) 'question_category_id': categoryId,
        if (typeId != null) 'type_id': typeId.toString(),
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the request headers
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final questions = (data['data']['questions'] as List)
            .map((json) => Question.fromJson(json))
            .toList();
        return questions;
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }
}
