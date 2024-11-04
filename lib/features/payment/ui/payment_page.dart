// lib/ui/payment_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/inbox/ui/inbox_page.dart';
import 'package:flutter_application_1/features/payment/service/payment_service.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page2.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';

class PaymentPage extends StatelessWidget {
  final PaymentService _paymentService = PaymentService();

  void _showSuccessOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/4416 1.png", // Replace with actual success image URL
                width: screenWidth * 0.5,
                height: screenWidth * 0.4,
                fit: BoxFit.fill,
              ),
              SizedBox(height: screenWidth * 0.04),
              Text(
                'Congratulations!\nYou have successfully subscribed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFC06500),
                  fontSize: screenWidth * 0.05,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final paymentOptions = _paymentService.fetchPaymentOptions(() => _showSuccessOverlay(context));

    return Scaffold(
       backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Inter',
                          color: Color(0xFFFF9933),
                        ),
                      ),
                    ),
                    Text(
                      'Payment',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Inter',
                        color: Color(0xFFFF9933),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InboxPage()),
                        );
                      },
                      child: Container(
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.12,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFFF9933)),
                          borderRadius: BorderRadius.circular(screenWidth * 0.06),
                        ),
                        child: Icon(Icons.inbox, color: Color(0xFFFF9933), size: screenWidth * 0.06),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.3,
                    height: screenWidth * 0.3,
                    decoration: ShapeDecoration(
                      color: Colors.transparent,
                      shape: CircleBorder(
                        side: BorderSide(width: 2, color: Color(0xFFFF9933)),
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/payment.png',
                        width: screenWidth * 0.2,
                        height: screenWidth * 0.15,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Text(
                      'Select a payment method to proceed with the subscription.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.05,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: paymentOptions.map((option) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: option.onTap,
                            child: Image.asset(
                              option.imagePath,
                              width: screenWidth * 0.2,
                              height: screenWidth * 0.2,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(screenWidth: screenWidth, screenHeight: screenHeight),
    );
  }
}