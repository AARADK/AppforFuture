import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/mainlogo/ui/main_logo_page.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/sign_up/ui/w1_page.dart';
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
      await hiveService.saveApiData('http://52.66.24.172:7001/frontend/Guests/login', ''); // Replace with your actual signup URL
    }

    if (existingOtpApiUrl == null) {
      await hiveService.saveOtpApiUrl('http://52.66.24.172:7001/frontend/Guests/ValidateOTP'); // Replace with your actual OTP validation URL
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
      title: 'Astrology App',
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

  Future<Widget> _getInitialPage() async {
    if (existingToken != null && existingToken!.isNotEmpty) {
      return DashboardPage();
    } else {
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
