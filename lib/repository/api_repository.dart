import 'dart:convert';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/models/question_model.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class ApiRepository {
  final String baseUrl = 'http://52.66.24.172:7001.com'; // Your API base URL

  Future<List<Category>> fetchCategories(int typeId) async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token'); // Retrieve the token from Hive storage

      final response = await http.get(
        Uri.parse('$baseUrl/frontend/GuestQuestion/GetQuestionCategory?type_id=$typeId'),
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the request headers
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data']['question_category'];
        return data.map((category) => Category.fromJson(category)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<List<Question>> fetchQuestions(String categoryId) async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token'); // Retrieve the token from Hive storage

      final response = await http.get(
        Uri.parse('$baseUrl/frontend/GuestQuestion/GetQuestion?question_category_id=$categoryId'),
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the request headers
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data']['questions'];
        return data.map((question) => Question.fromJson(question)).toList();
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }
}
