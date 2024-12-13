import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/CelestialBackgroundPainter.dart';
import 'package:flutter_application_1/components/NebulaBackgroundPainter.dart';
import 'package:flutter_application_1/components/animated_text.dart';
import 'package:flutter_application_1/features/sign_up/model/user_model.dart';
import 'package:flutter_application_1/features/sign_up/repo/sign_up_repo.dart';
import 'package:flutter_application_1/hive/hive_service.dart';
import 'package:intl/intl.dart';
// import 'package:video_player/video_player.dart';
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
  // late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // _videoController.dispose();  // Always dispose the controller
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
              'assets/images/w1_tablet.png', // Add your background image on top
              fit: BoxFit.cover,
            ),
          ),

         
 Positioned(
  top: 0, // Set this to 0 so the container starts at the top of the screen
  left: 0,
  right: 0,
  child: Opacity(
    opacity: 0.7, // Adjust the opacity of the GIF here (0.0 to 1.0)
    child: Container(
      height: MediaQuery.of(context).size.height, // 30% of screen height
      width: MediaQuery.of(context).size.width, // Full screen width
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationX(3.14159), // Upside down flip using rotation along the X-axis
        child: Image.asset(
          'assets/images/finalfog.gif', // Use the GIF here as the background
          fit: BoxFit.cover, // Ensures the GIF covers the container
          repeat: ImageRepeat.noRepeat, // Default GIF loop
        ),
      ),
    ),
  ),
),

          Positioned.fill(
          child:CelestialBackground(),
          ),
          // NebulaBackground(),

             // Foreground Content
       

        

          // Logo without rotation animation
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
                      child: Image.asset(
                        'assets/images/frame5_tablet.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : AspectRatio(
                    aspectRatio: 16.2 / 17,
                    child: FractionallySizedBox(
                      widthFactor: 0.6,
                      heightFactor: 0.6,
                      child: Image.asset(
                        'assets/images/frame5_tablet.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),

          // AnimatedTextWidget for displaying text
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.6,
            left: 0,
            right: 0,
            child: AnimatedTextWidget(
              texts: [
                "love",
                "career",
                "friendship",
                "business",
                "education",
                "partnership",
                "marriage"
              ],
              textStyle: TextStyle(
                fontSize:MediaQuery.of(context).size.height * 0.02 ,
                color: Colors.orange,
                fontWeight: FontWeight.w200,
                fontFamily: 'Inter',
              ),
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
                            borderSide: BorderSide(
                                color: Color(0xFFFF9933), width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Color(0xFFFF9933), width: 1.0),
                          ),
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'Inter',
                              fontSize: 12),
                          suffixIcon: _isLoading
                              ? CircularProgressIndicator()
                              : IconButton(
                                  icon: Icon(Icons.arrow_forward,
                                      color: Color(0xFFFF9933)),
                                  onPressed: () => _isLoginMode
                                      ? _loginUser(context, _isLoginMode)
                                      : _signupAndNavigateToOTP(
                                          context, _isLoginMode),
                                ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _toggleLoginMode,
                    child: Text(
                      _isLoginMode
                          ? 'Switch to Sign Up'
                          : 'I already have an account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromARGB(255, 225, 176, 137),
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w100),
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
      padding: const EdgeInsets.symmetric(
          horizontal: 30.0,
          vertical: 8.0), // Added vertical padding for spacing between fields
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label text widget
          Container(
            width:
                80, // Adjust the width as needed for label length consistency
            alignment: Alignment.centerLeft, // Align label text to the left
            child: Text(
              label,
              style: TextStyle(
                color: const Color.fromARGB(255, 255, 255, 255),
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
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10), // Adjusted padding inside text field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        BorderSide(color: Color(0xFFFF9933), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        BorderSide(color: Color(0xFFFF9933), width: 1.0),
                  ),
                  hintText: hintText,
                  hintStyle: TextStyle(
                      color: Colors.white70, fontFamily: 'Inter', fontSize: 12),
                ),
                keyboardType:
                    onTap == null ? TextInputType.text : TextInputType.datetime,
                style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Inter',
                    fontSize: 14), // Consistent font size for input
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
            MaterialPageRoute(
                builder: (context) =>
                    OtpOverlay(email: email, isLoginMode: isLoginMode)),
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
        _birthTimeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
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
            MaterialPageRoute(
                builder: (context) =>
                    OtpOverlay(email: user.email, isLoginMode: isLoginMode)),
          );
        } else {
          _showSnackBar(
              context, 'This email is already registered! Try logging in.');
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
