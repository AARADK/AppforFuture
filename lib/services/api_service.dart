import 'package:flutter_application_1/repository/api_repository.dart';

import '../models/category_model.dart';
import '../models/question_model.dart';

class ApiService {
  final ApiRepository _apiRepository = ApiRepository();

  Future<List<Category>> getCategories(int typeId) {
    return _apiRepository.fetchCategories(typeId);
  }

  Future<List<Question>> getQuestions(String categoryId) {
    return _apiRepository.fetchQuestions(categoryId);
  }
}
