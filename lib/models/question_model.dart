class Question {
  final String id;
  final String question;
  final int orderId;
  final int price;

  Question({
    required this.id,
    required this.question,
    required this.orderId,
    required this.price,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'],
      question: json['question'],
      orderId: json['order_id'],
      price: json['price'],
    );
  }
}
