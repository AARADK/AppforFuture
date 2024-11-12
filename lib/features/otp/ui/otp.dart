import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/mainlogo/ui/main_logo_page.dart';
import 'package:flutter_application_1/features/otp/service/otp_service.dart';

class OtpOverlay extends StatefulWidget {
  final String email;
  final bool isLoginMode;

  OtpOverlay({required this.email, required this.isLoginMode});

  @override
  _OtpOverlayState createState() => _OtpOverlayState();
}

class _OtpOverlayState extends State<OtpOverlay> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final OtpService _otpService = OtpService();
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFFFF9933)),
        title: Text(
          'OTP Verification',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.normal,
            fontFamily: 'Inter',
            color: Color(0xFFFF9933),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: screenWidth * 0.1,
                    child: TextField(
                      controller: _otpControllers[index],
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFF9933), width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12, width: 2.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        counterText: '', // Remove character counter
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < 5) {
                            FocusScope.of(context).nextFocus();
                          }
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                        setState(() {}); // Update button state
                      },
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: _isOtpComplete() ? Color(0xFFFF9933) : Colors.grey,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    fixedSize: Size(screenWidth * 0.6, screenHeight * 0.05),
                    shadowColor: Colors.black,
                    elevation: 10,
                  ),
                  onPressed: _isOtpComplete() && !_isVerifying ? _verifyOtp : null,
                  child: _isVerifying
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Send',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isOtpComplete() {
    return _otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  void _verifyOtp() async {
    String enteredOtp = _otpControllers.map((controller) => controller.text).join();

    if (enteredOtp.length == 6) {
      setState(() {
        _isVerifying = true;
      });

      try {
        bool isVerified = await _otpService.verifyOtp(enteredOtp, widget.email);

        if (isVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => widget.isLoginMode ? DashboardPage() : MainLogoPage()),
          );
          _otpControllers.forEach((controller) => controller.clear());
        } else {
          _showSnackBar('Invalid OTP. Please try again.');
          _otpControllers.forEach((controller) => controller.clear());
        }
      } catch (e) {
        _showSnackBar('An error occurred. Please try again.');
      } finally {
        setState(() {
          _isVerifying = false;
        });
      }
    } else {
      _showSnackBar('Please enter a valid OTP');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
