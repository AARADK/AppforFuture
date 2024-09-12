// ask_question_service.dart
import 'package:flutter_application_1/features/ask_a_question/model2/model2.dart';
import 'package:flutter_application_1/features/ask_a_question/repo2/repo2.dart';

class AskQuestionService {
  final AskQuestionRepository _repository = AskQuestionRepository();

  // Fetch categories from the repository
  Future<List<QuestionCategory>> getCategories() async {
    try {
      final categories = await _repository.fetchCategories();
      return categories;
    } catch (e) {
      throw Exception('Error getting categories: $e');
    }
  }

  // Fetch questions based on category ID from the repository
  Future<List<Question>> getQuestionsByCategoryId(String categoryId) async {
    try {
      final questions = await _repository.fetchQuestions(categoryId: categoryId);
      return questions;
    } catch (e) {
      throw Exception('Error getting questions: $e');
    }
  }

  // Fetch all questions based on type ID
  Future<List<Question>> getQuestionsByTypeId(int typeId) async {
    try {
      final questions = await _repository.fetchQuestions(typeId: typeId);
      return questions;
    } catch (e) {
      throw Exception('Error getting questions: $e');
    }
  }
}
