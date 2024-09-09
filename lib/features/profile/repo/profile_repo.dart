import 'package:flutter_application_1/hive/hive_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileRepo {
  final HiveService _hiveService = HiveService();

  // Method to update guest profile
  Future<bool> updateGuestProfile(Map<String, dynamic> updateData) async {
    String apiUrl = 'http://52.66.24.172:7001/frontend/Guests/UpdateGuestProfile'; // Replace with your actual URL
    String? token = await _hiveService.getToken();

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updateData), // Sending the update data in the body
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['error_code'] == "0") {
        return true; // Update successful
      } else {
        print('Error updating profile: ${responseData['message']}');
      }
    } else {
      print('Failed to update profile: ${response.statusCode}');
    }
    return false; // Update failed
  }

  // Method to get profile data
  Future<Map<String, dynamic>?> getProfile() async {
    // Ensure that the guest profile is updated before fetching
    bool updateSuccess = await updateGuestProfile({
      // Provide necessary data for updating the profile here
    });

    if (updateSuccess) {
      String apiUrl = 'http://52.66.24.172:7001/frontend/Guests/Get'; // Replace with your actual URL
      String? token = await _hiveService.getToken();

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': token != null ? 'Bearer $token' : '',
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['error_code'] == "0") {
          return responseData['data']['item'];
        } else {
          print('Error fetching profile: ${responseData['message']}');
        }
      } else {
        print('Failed to fetch profile: ${response.statusCode}');
      }
    }
    return null;
  }
}
