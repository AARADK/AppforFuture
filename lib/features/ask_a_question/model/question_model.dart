class Question {
  final String id;
  final String question;
  final double price;

  Question({required this.id, required this.question, required this.price});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'],
      question: json['question'],
      price: json['price'].toDouble(),
    );
  }
}
