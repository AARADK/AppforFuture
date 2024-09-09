import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _boxName = 'settings';

  // Initialize Hive
  Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  // Save API URL and token
  Future<void> saveApiData(String apiUrl, String token) async {
    var box = Hive.box(_boxName);
    await box.put('apiUrl', apiUrl);
    await box.put('token', token);
  }

  // Save OTP Validation API URL
  Future<void> saveOtpApiUrl(String otpApiUrl) async {
    var box = Hive.box(_boxName);
    await box.put('otpApiUrl', otpApiUrl);
  }

  // Save token
  Future<void> saveToken(String token) async {
    var box = Hive.box(_boxName);
    await box.put('token', token);
  }

  // Save OTP
  Future<void> saveOtp(String otp) async {
    var box = Hive.box(_boxName);
    await box.put('otp', otp);
  }

  // Retrieve API URL
  Future<String?> getApiUrl() async {
    var box = Hive.box(_boxName);
    return box.get('apiUrl');
  }

  // Retrieve OTP Validation API URL
  Future<String?> getOtpApiUrl() async {
    var box = Hive.box(_boxName);
    return box.get('otpApiUrl');
  }

  // Retrieve token
  Future<String?> getToken() async {
    var box = Hive.box(_boxName);
    return box.get('token');
  }

  // Retrieve OTP
  Future<String?> getOtp() async {
    var box = Hive.box(_boxName);
    return box.get('otp');
  }

  // Clear OTP
  Future<void> clearOtp() async {
    var box = Hive.box(_boxName);
    await box.delete('otp');
  }

  // Clear token
  Future<void> clearToken() async {
    var box = Hive.box(_boxName);
    await box.delete('token');
  }

  // Clear all data (if needed)
  Future<void> clearAll() async {
    var box = Hive.box(_boxName);
    await box.clear();
  }
}
