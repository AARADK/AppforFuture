import 'dart:convert';
import 'dart:typed_data';

class Offer {
  final String id;
  final String name;
  final String description;
  final String? imageBlob; // Base64-encoded image
  final DateTime effectiveFrom;
  final DateTime effectiveTo;
  final bool active;
  final double price;
  final int horoscopeQuestionCount;
  final int compatibilityQuestionCount;
  final String auspiciousQuestionId;

  Offer({
    required this.id,
    required this.name,
    required this.description,
    this.imageBlob,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.active,
    required this.price,
    required this.horoscopeQuestionCount,
    required this.compatibilityQuestionCount,
    required this.auspiciousQuestionId,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      imageBlob: json['image_blob'],
      effectiveFrom: DateTime.parse(json['effective_from']),
      effectiveTo: DateTime.parse(json['effective_to']),
      active: json['active'],
      price: (json['price'] as num).toDouble(),
      horoscopeQuestionCount: json['horoscope_question_count'],
      compatibilityQuestionCount: json['compatibility_question_count'],
      auspiciousQuestionId: json['auspicious_question_id'],
    );
  }

  // Convert Base64 string to Uint8List for image display
  Uint8List? get imageData {
    if (imageBlob != null) {
      return base64Decode(imageBlob!);
    }
    return null;
  }
}
