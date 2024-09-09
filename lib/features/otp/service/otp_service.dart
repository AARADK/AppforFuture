import 'dart:convert';
import 'package:flutter_application_1/hive/hive_service.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class OtpService {
  final HiveService _hiveService = HiveService(); // Create an instance of HiveService

  Future<bool> verifyOtp(String otp, String email) async {
    final box = Hive.box('settings');
    final baseUrl = await box.get('otpApiUrl'); // Retrieve OTP validation URL

    if (baseUrl != null) {
      final url = '$baseUrl?email=$email&otp=$otp'; // Construct the full URL
      final response = await http.get(Uri.parse(url)); // Call the API

      if (response.statusCode == 200) {
        // Handle successful response
        var responseData = jsonDecode(response.body);
        print('OTP validated successfully: ${response.body}');
        
        // Save the token if present in the response
        if (responseData['data'] != null && responseData['data']['token'] != null) {
          await _hiveService.saveToken(responseData['data']['token']); // Save the token
        }

        return true; // Indicate successful verification
      } else {
        // Handle error response
        print('Error validating OTP: ${response.statusCode}');
        return false; // Indicate failure
      }
    } else {
      print('Base URL not found in Hive.');
      return false; // Indicate failure
    }
  }
}
