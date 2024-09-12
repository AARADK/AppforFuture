class Category {
  final String id;
  final String category;
  final int orderId;
  final bool active;

  Category({
    required this.id,
    required this.category,
    required this.orderId,
    required this.active,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      category: json['category'],
      orderId: json['order_id'],
      active: json['active'],
    );
  }
}
