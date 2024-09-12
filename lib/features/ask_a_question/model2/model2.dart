// question_category_model.dart
class QuestionCategory {
  final String id;
  final String category;
  final int orderId;
  final int categoryTypeId;
  final bool active;

  QuestionCategory({
    required this.id,
    required this.category,
    required this.orderId,
    required this.categoryTypeId,
    required this.active,
  });

  factory QuestionCategory.fromJson(Map<String, dynamic> json) {
    return QuestionCategory(
      id: json['_id'],
      category: json['category'],
      orderId: json['order_id'],
      categoryTypeId: json['category_type_id'],
      active: json['active'],
    );
  }
}

// question_model.dart
class Question {
  final String id;
  final String question;
  final int orderId;
  final String questionCategoryId;
  final bool active;
  final double price;

  Question({
    required this.id,
    required this.question,
    required this.orderId,
    required this.questionCategoryId,
    required this.active,
    required this.price,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'],
      question: json['question'],
      orderId: json['order_id'],
      questionCategoryId: json['question_category_id'],
      active: json['active'],
      price: json['price'].toDouble(),
    );
  }
}
