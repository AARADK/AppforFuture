import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/sign_up/model/user_model.dart';
import 'package:flutter_application_1/features/sign_up/repo/sign_up_repo.dart';
import 'package:flutter_application_1/features/sign_up/ui/detail_input_field.dart';
import 'package:flutter_application_1/hive/hive_service.dart';
import 'package:intl/intl.dart';
import '../../otp/ui/otp.dart';

class W1Page extends StatefulWidget {
  @override
  _W1PageState createState() => _W1PageState();
}

class _W1PageState extends State<W1Page> {
  TextEditingController _birthDateController = TextEditingController();
  TextEditingController _birthTimeController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  SignUpRepo _signUpRepo = SignUpRepo();
  HiveService _hiveService = HiveService();

  bool _isLoginMode = false;
  bool _isLoading = false; // Variable to track loading state
  bool? state = SignUpRepo().getState();

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/w1.png',
              fit: BoxFit.cover,
            ),
          ),
          if (isTablet)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Image.asset(
                  'assets/images/frame5_tablet.png',
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Positioned(
              top: MediaQuery.of(context).size.height * 0.0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.5,
              child: AspectRatio(
                aspectRatio: 16.2 / 17,
                child: Image.asset(
                  'assets/images/Frame 5.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 50.0 : 16.0,
                vertical: isTablet ? 30.0 : 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isTablet)
                    SizedBox(height: MediaQuery.of(context).size.height * 0.4)
                  else
                    SizedBox(height: MediaQuery.of(context).size.height * 0.45),
                  Text(
                    'Welcome',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFFFF9933),
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 10),
                  // Toggle Text for Login Mode
                  GestureDetector(
                    onTap: _toggleLoginMode,
                    child: Text(
                      _isLoginMode ? 'Switch to Sign Up' : 'I already have an account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 10),
                  // Detail Sections
                  if (!_isLoginMode) ...[
                    DetailSection(
                      label: 'I am',
                      hintText: 'Enter your name',
                      keyboardType: TextInputType.text,
                      controller: _nameController,
                    ),
                    DetailSection(
                      label: 'From',
                      hintText: 'Enter your location (city_id)',
                      keyboardType: TextInputType.text,
                      controller: _locationController,
                    ),
                    DetailSection(
                      label: 'Born on',
                      hintText: 'Enter your birth date',
                      keyboardType: TextInputType.datetime,
                      onTap: () => _selectDate(context),
                      controller: _birthDateController,
                    ),
                    DetailSection(
                      label: 'At',
                      hintText: 'Enter your birth time (HH:MM)',
                      keyboardType: TextInputType.datetime,
                      onTap: () => _selectTime(context),
                      controller: _birthTimeController,
                    ),
                  ],
                  SizedBox(height: isTablet ? 20 : 10),
                  // Email Section
                  Text(
                    'Please enter your email address to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w200,
                      color: Color(0xFFFF9933),
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            borderSide: BorderSide(color: Color(0xFFFF9933), width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            borderSide: BorderSide(color: Color(0xFFFF9933), width: 2.0),
                          ),
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: Colors.white70, fontFamily: 'Inter'),
                          suffixIcon: _isLoading
                              ? CircularProgressIndicator() // Show loading indicator
                              : IconButton(
                                  icon: Icon(Icons.arrow_forward, color: Color(0xFFFF9933)),
                                  onPressed: () => _isLoginMode ? _loginUser(context) : _signupAndNavigateToOTP(context),
                                ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to toggle between signup and login modes
  void _toggleLoginMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      // Clear all fields when switching modes
      _nameController.clear();
      _birthDateController.clear();
      _birthTimeController.clear();
      _locationController.clear();
      _emailController.clear();
    });
  }

  void _loginUser(BuildContext context) async {
    if (_emailController.text.isNotEmpty) {
      String email = _emailController.text;

      setState(() {
        _isLoading = true; // Start loading
      });

      try {
        // Attempt to login the user
        bool isLoggedIn = await _signUpRepo.login(email);

        if (isLoggedIn) {
          // Login successful, navigate to OTP page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OtpOverlay(email: email,state: state)),
          );
        } else {
          // Email not registered, show appropriate message
          _showSnackBar(context, 'Email not registered. Please sign up.');
        }
      } catch (e) {
        print('Login error: $e'); // Debug statement
        _showSnackBar(context, 'An error occurred during login.');
      } finally {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    } else {
      _showSnackBar(context, 'Please enter your email.');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _birthTimeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}'; // 24-hour format
      });
    }
  }

  void _signupAndNavigateToOTP(BuildContext context) async {
    if (_validateInputs()) {
      UserModel user = UserModel(
        name: _nameController.text,
        email: _emailController.text,
        cityId: _locationController.text,
        dob: _birthDateController.text,
        tob: _birthTimeController.text,
      );

      setState(() {
        _isLoading = true; // Start loading
      });

      try {
        // Attempt to sign up the user
        bool isSignedUp = await _signUpRepo.signUp(user);
        if (isSignedUp) {
          // Signup successful, navigate to OTP page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OtpOverlay(email: user.email, state: state)),
          );
        } else {
          // Email already registered, show appropriate message
          _showSnackBar(context, 'This email is already registered! Try logging in.');
        }
      } catch (e) {
        print('Signup error: $e');
        _showSnackBar(context, 'An error occurred during signup.');
      } finally {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    }
  }

  bool _validateInputs() {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _locationController.text.isNotEmpty &&
        _birthDateController.text.isNotEmpty &&
        _birthTimeController.text.isNotEmpty;
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
