import 'package:flutter_application_1/features/horoscope/model/horoscope_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart'; // Make sure you have hive dependency for secure storage

class HoroscopeRepository {
  // Function to fetch horoscope data from the API
  Future<Horoscope> fetchHoroscopeData(String date) async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token'); // Retrieve the token from Hive storage

      final url = 'http://52.66.24.172:7001/frontend/Guests/GetDashboardData?date=$date';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the request headers
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']['horoscope'];
        return Horoscope.fromJson(data);
      } else {
        throw Exception('Failed to load horoscope data');
      }
    } catch (e) {
      throw Exception('Error fetching horoscope data: $e');
    }
  }
}
