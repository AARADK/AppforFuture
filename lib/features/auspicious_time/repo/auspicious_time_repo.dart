import 'package:flutter_application_1/features/auspicious_time/model/auspicious_time_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart'; // Ensure Hive is added for secure storage

class AuspiciousRepository {
  // Function to fetch auspicious data from the API
  Future<Auspicious> fetchAuspiciousData(String date) async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token'); // Retrieve the token from Hive storage

      // final url = 'http://45.117.153.217:3001/frontend/Guests/GetDashboardData?date=$date';
       final url = 'http://45.117.153.217:3001/frontend/Guests/GetDashboardData?date=2024-10-06';

      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the request headers
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']['auspicious'];
        return Auspicious.fromJson(data);
      } else {
        throw Exception('Failed to load auspicious data');
      }
    } catch (e) {
      throw Exception('Error fetching auspicious data: $e');
    }
  }
}
