class QuestionCategory {
  final String id;
  final String category;

  QuestionCategory({required this.id, required this.category});

  factory QuestionCategory.fromJson(Map<String, dynamic> json) {
    return QuestionCategory(
      id: json['_id'],
      category: json['category'],
    );
  }
}
