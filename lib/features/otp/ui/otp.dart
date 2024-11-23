import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/mainlogo/ui/main_logo_page.dart';
import 'package:flutter_application_1/features/otp/service/otp_service.dart';
import 'package:flutter_application_1/features/sign_up/repo/sign_up_repo.dart';

class OtpOverlay extends StatefulWidget {
  final String email;
  final bool isLoginMode;

  OtpOverlay({required this.email, required this.isLoginMode});

  @override
  _OtpOverlayState createState() => _OtpOverlayState();
}

class _OtpOverlayState extends State<OtpOverlay> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final OtpService _otpService = OtpService();
  bool _isVerifying = false;

  int _timerSeconds = 60;
  Timer? _timer;
  bool timeup = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _otpControllers.forEach((controller) => controller.dispose());
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 60;
      timeup = false;
    });

    _otpControllers.forEach((controller) => controller.clear()); // Clear fields

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          timeup = true; // Timer has expired
          _otpControllers.forEach((controller) => controller.clear());
        });
      }
    });
  }

  String _formattedTime() {
    final minutes = (_timerSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timerSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

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
            color: Color.fromARGB(255, 77, 76, 76),
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
                          borderSide:
                              BorderSide(color: Color(0xFFFF9933), width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black12, width: 2.0),
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
                      enabled: !timeup, // Disable input when timer expires
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
              Text(
                _formattedTime(),
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10),
              // Show resend OTP link only after time is up
              if (timeup)
                RichText(
                  text: TextSpan(
                    text: "Didn't receive OTP? ",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[600],
                    ),
                    children: [
                      TextSpan(
                        text: "Resend",
                        style: TextStyle(
                          color: Color(0xFFFF9933),
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = _resendOtp,
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: _isOtpComplete() && !timeup
                        ? Color(0xFFFF9933)
                        : Colors.grey,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.01),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    fixedSize: Size(screenWidth * 0.6, screenHeight * 0.05),
                    shadowColor: Colors.black,
                    elevation: 10,
                  ),
                  onPressed: _isOtpComplete() && !_isVerifying && !timeup
                      ? _verifyOtp
                      : null,
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
    String enteredOtp =
        _otpControllers.map((controller) => controller.text).join();

    if (enteredOtp.length == 6 && timeup == false) {
      setState(() {
        _isVerifying = true;
      });

      try {
        bool isVerified =
            await _otpService.verifyOtp(enteredOtp, widget.email, timeup);

        if (isVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    widget.isLoginMode ? DashboardPage() : MainLogoPage()),
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

  void _resendOtp() async {
    try {
      bool success =
          await SignUpRepo().login(widget.email); // Call the resendOtp method

      if (success) {
        _startTimer(); // Restart the timer
        _showSnackBar('OTP resent successfully.');
      } else {
        _showSnackBar('Failed to resend OTP. Please try again.');
      }
    } catch (e) {
      _showSnackBar('An error occurred while resending OTP.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
