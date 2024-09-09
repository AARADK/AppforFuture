import 'dart:convert';
import 'package:flutter_application_1/features/dashboard/model/dashboard_model.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class DashboardRepository {
  // Function to fetch dashboard data from the API
  Future<DashboardData> fetchDashboardData(String date) async {
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
        final data = json.decode(response.body);
        return DashboardData.fromJson(data);
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard data: $e');
    }
  }

  Future<List<String>> fetchOfferImages() async {
    // Simulate a network call or local data fetching
    return Future.delayed(
      Duration(seconds: 1),
      () => [
        'assets/images/christmas.jpg',
        'assets/images/newyear.jpg',
        'assets/images/marriage.jpg',
        'assets/images/11142.jpg',
        'assets/images/planets.jpg',
      ],
    );
  }
}
