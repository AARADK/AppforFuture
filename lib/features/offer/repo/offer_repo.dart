import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:flutter_application_1/features/offer/model/offer_model.dart';

class OfferRepository {
  final String offerApiUrl = "http://45.117.153.217:3001/frontend/GuestBundle/Get?sort_by=price";
  final String questionApiUrl = "http://45.117.153.217:3001/frontend/GuestQuestion/GetQuestion?type_id=3";

  Future<String?> _getToken() async {
    final box = Hive.box('settings');
    return await box.get('token');
  }

  Future<List<Offer>> fetchOffers() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(offerApiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the request headers
        },
      ).timeout(const Duration(seconds: 30)); // Add timeout for the request

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        Map<String, dynamic> data = jsonData['data']; // Access the 'data' object
        List<dynamic> offersList = data['list']; // Access the 'list' within 'data'
        
        return offersList.map((offer) => Offer.fromJson(offer)).toList();
      } else {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load offers');
      }
    } catch (e) {
      throw Exception('Error fetching offers: $e');
    }
  }

  Future<Map<String, String>> fetchQuestions() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(questionApiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the request headers
        },
      ).timeout(const Duration(seconds: 30)); // Add timeout for the request

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        Map<String, dynamic> data = jsonData['data'];
        List<dynamic> questionsList = data['questions'];

        // Map the question ID to the question text
        return {
          for (var question in questionsList) question['_id']: question['question']
        };
      } else {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }
}
