import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/mainlogo/ui/main_logo_page.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/sign_up/ui/w1_page.dart';
import 'package:hive/hive.dart';
import 'hive/hive_service.dart'; // Import your Hive service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  HiveService hiveService = HiveService();
  try {
    await hiveService.initHive();

    // Check if the API URL already exists in Hive
    final existingToken = await hiveService.getToken();
    final existingApiUrl = await hiveService.getApiUrl();
    final existingOtpApiUrl = await hiveService.getOtpApiUrl();

    if (existingApiUrl == null) {
      await hiveService.saveApiData('http://145.223.23.200:3002/frontend/Guests/login', ''); // signup URL
    }

    if (existingOtpApiUrl == null) {
      await hiveService.saveOtpApiUrl('http://145.223.23.200:3002/frontend/Guests/ValidateOTP'); //  OTP validation URL
    }

    runApp(MyApp(existingToken: existingToken));
  } catch (e) {
    print('Error initializing Hive: $e');
    runApp(ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  final String? existingToken;

  MyApp({this.existingToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      title: 'myFutureTime',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<Widget>(
        future: _getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return ErrorApp();
          } else {
            return snapshot.data!;
          }
        },
      ),
      routes: {
        '/dashboard': (context) => DashboardPage(),
        '/horoscope': (context) => HoroscopePage(),
        '/compatibility': (context) => CompatibilityPage(),
        '/auspiciousTime': (context) => AuspiciousTimePage(),
        '/w1': (context) => W1Page(),
        '/mainlogo': (context) => MainLogoPage(),
      },
    );
  }

  Future<Widget> _getInitialPage()  async {
  final box = Hive.box('settings');
  final guestProfile = await box.get('guest_profile');
  final token = await box.get('token');

  if (token == null) {
    return W1Page();
  } else if (token != null && guestProfile == null) {
    // Token exists but guest_profile is null -> MainLogoPage
    return MainLogoPage();
  } else if (token != null && guestProfile != null) {
    // Both token and guest_profile exist -> DashboardPage
    return DashboardPage();
  } else {
    // No token -> Onboarding/Signup page
    return W1Page();
  }
}
}
class ErrorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error',
      home: Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('Failed to initialize the app.')),
      ),
    );
  }
}
