class Auspicious {
  final int rashiId;
  final double rating;
  final String description;

  Auspicious({
    required this.rashiId,
    required this.rating,
    required this.description,
  });

  factory Auspicious.fromJson(Map<String, dynamic> json) {
    return Auspicious(
      rashiId: json['rashi_id'] as int,
      rating: json['rating'] as double,
      description: json['description'] as String,
    );
  }
}
