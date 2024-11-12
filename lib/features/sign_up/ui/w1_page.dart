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

class _W1PageState extends State<W1Page> with TickerProviderStateMixin {
  TextEditingController _birthDateController = TextEditingController();
  TextEditingController _birthTimeController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  SignUpRepo _signUpRepo = SignUpRepo();
  HiveService _hiveService = HiveService();

  bool _isLoginMode = false;
  bool _isLoading = false;

  // Animation controllers for logo rotation and text animation
  late AnimationController _animationController;
  late AnimationController _textAnimationController;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _textPositionAnimation;
  late Animation<double> _textFadeAnimation;
  
  final List<String> animatedTexts = ["love", "career", "friendship", "business"];
  int currentTextIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize logo animation controller
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    // Define rotation animation for logo
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Initialize text animation controller
    _textAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    // Define position and fade animations for the animated text
    _textPositionAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset(0, -0.2)).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeInOut),
    );

    _textFadeAnimation = Tween<double>(begin: 0.9, end: 0.0).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeIn),
    );

    // Start logo animation and text animation
    _animationController.forward();
    _startTextAnimation();
  }

  void _startTextAnimation() {
    Future.delayed(Duration(seconds: 1), () {
      _textAnimationController.forward().whenComplete(() {
        setState(() {
          // Loop through each text in the list
          currentTextIndex = (currentTextIndex + 1) % animatedTexts.length;
        });
        _textAnimationController.reset();
        _startTextAnimation();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/w1_tablet.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Logo with rotation animation
          Positioned(
            top: MediaQuery.of(context).size.height * 0.0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: isTablet
                ? Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.8,
                      heightFactor: 0.8,
                      child: AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..translate(0.0, -20.0 * (1 - _rotationAnimation.value))
                              ..rotateZ(2 * 3.14159 * _rotationAnimation.value),
                            child: Image.asset(
                              'assets/images/frame5_tablet.png',
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : AspectRatio(
                    aspectRatio: 16.2 / 17,
                    child: FractionallySizedBox(
                      widthFactor: 0.6,
                      heightFactor: 0.6,
                      child: AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..translate(0.0, -20.0 * (1 - _rotationAnimation.value))
                              ..rotateZ(2 * 3.14159 * _rotationAnimation.value),
                            child: Image.asset(
                              'assets/images/frame5_tablet.png',
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
          
          // Inside the Positioned widget for the animated text:
Positioned(
  bottom: MediaQuery.of(context).size.height * 0.6,
  left: 0,
  right: 0,
  child: AnimatedBuilder(
    animation: _textAnimationController,
    builder: (context, child) {
      return Opacity(
        opacity: _textFadeAnimation.value,
        child: Transform.translate(
          offset: _textPositionAnimation.value * 200,
          child: Text(
            animatedTexts[currentTextIndex],  // The animated text
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,  // Customize font size
              color: Colors.orange,  // Customize color
              fontWeight: FontWeight.w200,  // Set font weight
              fontFamily: 'Inter',  // Set font family (you can replace 'Arial' with the font of your choice)
            ),
          ),
        ),
      );
    },
  ),
),

          
          // Form section
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
                  SizedBox(height: isTablet ? 20 : 10),
                 if (!_isLoginMode) ...[
                    _buildTextField(
                      controller: _nameController,
                      label: 'I am',
                      hintText: 'Name',
                    ),
                    SizedBox(height: isTablet ? 20 : 10),
                    _buildTextField(
                      controller: _locationController,
                      label: 'From',
                      hintText: 'Location',
                    ),
                    SizedBox(height: isTablet ? 20 : 10),
                    _buildTextField(
                      controller: _birthDateController,
                      label: 'Born on',
                      hintText: 'Birth date',
                      onTap: () => _selectDate(context),
                    ),
                    SizedBox(height: isTablet ? 20 : 10),
                    _buildTextField(
                      controller: _birthTimeController,
                      label: 'At',
                      hintText: 'Birth time',
                      onTap: () => _selectTime(context),
                    ),
                  ],
                  SizedBox(height: isTablet ? 20 : 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Color(0xFFFF9933), width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Color(0xFFFF9933), width: 1.0),
                          ),
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: Colors.white70, fontFamily: 'Inter', fontSize: 12),
                          suffixIcon: _isLoading
                              ? CircularProgressIndicator()
                              : IconButton(
                                  icon: Icon(Icons.arrow_forward, color: Color(0xFFFF9933)),
                                  onPressed: () => _isLoginMode
                                      ? _loginUser(context, _isLoginMode)
                                      : _signupAndNavigateToOTP(context, _isLoginMode),
                                ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _toggleLoginMode,
                    child: Text(
                      _isLoginMode ? 'Switch to Sign Up' : 'I already have an account',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 14),
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
   Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String hintText,
  GestureTapCallback? onTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0), // Added vertical padding for spacing between fields
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label text widget
        Container(
          width: 80, // Adjust the width as needed for label length consistency
          alignment: Alignment.centerLeft, // Align label text to the left
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'Inter',
              fontSize: 12, // Smaller, consistent font size
            ),
          ),
        ),
        SizedBox(width: 10), // Space between label and text field
        // Text field container
        Expanded(
          child: Container(
            height: 40,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Adjusted padding inside text field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Color(0xFFFF9933), width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Color(0xFFFF9933), width: 1.0),
                ),
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.white70, fontFamily: 'Inter', fontSize: 12),
              ),
              keyboardType: onTap == null ? TextInputType.text : TextInputType.datetime,
              style: TextStyle(color: Colors.white70, fontFamily: 'Inter', fontSize: 14), // Consistent font size for input
              onTap: onTap,
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
      _nameController.clear();
      _birthDateController.clear();
      _birthTimeController.clear();
      _locationController.clear();
      _emailController.clear();
    });
  }

  void _loginUser(BuildContext context, bool isLoginMode) async {
    if (_emailController.text.isNotEmpty) {
      String email = _emailController.text;

      setState(() {
        _isLoading = true;
      });

      try {
        bool isLoggedIn = await _signUpRepo.login(email);

        if (isLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OtpOverlay(email: email, isLoginMode: isLoginMode)),
          );
        } else {
          _showSnackBar(context, 'Email not registered. Please sign up.');
        }
      } catch (e) {
        print('Login error: $e');
        _showSnackBar(context, 'An error occurred during login.');
      } finally {
        setState(() {
          _isLoading = false;
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
        _birthTimeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _signupAndNavigateToOTP(BuildContext context, bool isLoginMode) async {
    if (_validateInputs()) {
      UserModel user = UserModel(
        name: _nameController.text,
        email: _emailController.text,
        cityId: _locationController.text,
        dob: _birthDateController.text,
        tob: _birthTimeController.text,
      );

      setState(() {
        _isLoading = true;
      });

      try {
        bool isSignedUp = await _signUpRepo.signUp(user);
        if (isSignedUp) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OtpOverlay(email: user.email, isLoginMode: isLoginMode)),
          );
        } else {
          _showSnackBar(context, 'This email is already registered! Try logging in.');
        }
      } catch (e) {
        print('Signup error: $e');
        _showSnackBar(context, 'An error occurred during signup.');
      } finally {
        setState(() {
          _isLoading = false;
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
        duration: Duration(seconds: 2),
      ),
    );
  }
}
