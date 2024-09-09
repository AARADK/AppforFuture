import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/astrologers/ui/astrologer_page.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page2.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/profile/ui/profile_details.dart';
import 'package:flutter_application_1/menu.dart';

class MenuService {
  static void navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileDetails()),
    );
  }

  static void navigateToHoroscope(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HoroscopePage()),
    );
  }

  static void navigateToAuspiciousTime(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AuspiciousTimePage()),
    );
  }

  static void navigateToCompatibility(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CompatibilityPage()),
    );
  }

  static void navigateToAstrologers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OurAstrologersPage()),
    );
  }

  static void navigateToContactUs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactUsPage()),
    );
  }

  static void navigateToAboutUs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AboutUsPage()),
    );
  }
}