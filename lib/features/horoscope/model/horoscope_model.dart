class Horoscope {
  final int rashiId;
  final int rating;
  final String description;

  Horoscope({
    required this.rashiId,
    required this.rating,
    required this.description,
  });

  factory Horoscope.fromJson(Map<String, dynamic> json) {
    return Horoscope(
      rashiId: json['rashi_id'] as int,
      rating: json['rating'] as int,
      description: json['description'] as String,
    );
  }
}
