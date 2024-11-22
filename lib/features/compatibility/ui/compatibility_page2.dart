import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/components/buildcirclewithname.dart';
import 'package:flutter_application_1/components/categorydropdown.dart';
import 'package:flutter_application_1/components/custom_button.dart';
import 'package:flutter_application_1/components/questionlistwidget.dart';
import 'package:flutter_application_1/components/topnavbar.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart';
import 'package:flutter_application_1/features/ask_a_question/repo/ask_a_question_repo.dart';
import 'package:flutter_application_1/features/ask_a_question/ui/ask_a_question_page.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/inbox/ui/inbox_page.dart';
import 'package:flutter_application_1/features/partner/ui/partner_details_page.dart';
import 'package:flutter_application_1/features/payment/ui/payment_page.dart';
import 'package:flutter_application_1/features/profile/model/profile_model.dart';
import 'package:flutter_application_1/features/profile/repo/profile_repo.dart';
import 'package:flutter_application_1/features/profile/service/profile_services.dart';
import 'package:flutter_application_1/features/support/ui/support_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompatibilityPage2 extends StatefulWidget {
  @override
  _CompatibilityPage2State createState() => _CompatibilityPage2State();
}

class _CompatibilityPage2State extends State<CompatibilityPage2> {
  final Color primaryColor = Color(0xFFFF9933);
  ProfileModel? _profile;
  Map<String, dynamic>? _compatibilityData;
  bool _isLoading = true;
  String? _errorMessage;
  String? _person2Name = 'Person 2'; // Variable to store Person 2's name
  late Future<List<Question>> _questionsFuture; // Future for Horoscope questions
  final AskQuestionRepository _askQuestionRepository = AskQuestionRepository(); // Instantiate the repository
   String? _editedName = ProfileRepo().getName();
String? _editedDob = '';
String? _editedCityId = '';
String? _editedTob = '';
bool isEditing = false;

String? _editedName2 = '';
String? _editedDob2 = '';
String? _editedCityId2 = '';
String? _editedTob2 = '';
bool isEditing2 = false;

Color _iconColor = Colors.black; // Initial color

//For editable dialog 1
final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController cityIdController = TextEditingController();
  final TextEditingController tobController = TextEditingController();
  
  //For editable dialog 2
  final TextEditingController name2Controller = TextEditingController();
  final TextEditingController dob2Controller = TextEditingController();
  final TextEditingController cityId2Controller = TextEditingController();
  final TextEditingController tob2Controller = TextEditingController();

  void _updateIconColor() {
    setState(() {
      _iconColor = _iconColor == Colors.black ? Color(0xFFFF9933) : Colors.black;
    });
  }



  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _questionsFuture = _askQuestionRepository.fetchQuestionsByTypeId(2);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEditableProfileDialog2(context);
    });

  }

  Future<void> _fetchProfileData() async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token');
      String url = 'http://145.223.23.200:3002/frontend/Guests/Get';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['error_code'] == "0") {
          setState(() {
            _profile = ProfileModel.fromJson(responseData['data']['item']);
            _compatibilityData = responseData['data']['compatibility'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = responseData['message'];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load compatibility data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

 
@override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    backgroundColor: Colors.white,
    body: Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TopNavBar(
                  title: 'Specific Compatibility',
                  onLeftButtonPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CompatibilityPage()),
                    );
                  },
                  onRightButtonPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SupportPage()),
                    );
                  },
                  leftIcon: Icons.arrow_back, // Icon for the left side
                  rightIcon: Icons.help,     // Icon for the right side
                ),

                SizedBox(height: screenHeight * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circle and Name for Profile 1
                    Column(
                      children: [
                        CircleWithNameWidget(
                          assetPath: 'assets/images/virgo.png',
                          name: _editedName ?? _profile?.name ?? 'no name available',
                          screenWidth: screenWidth,
                          onTap: () {
                            if (_profile?.name != null) {
                              _showProfileDialog(context, _profile!);
                            } else {
                              print("no name");
                            }
                          },
                          primaryColor: Color(0xFFFF9933),
                        ),
                        SizedBox(height: 8), // Space between name and 'Edit' text
                        GestureDetector(
                          onTap: () {
                            _showEditableProfileDialog(context); // Function for the first profile
                          },
                          child: Text(
                            'Edit', // 'Edit' text below the name
                            style: TextStyle(
                              fontSize: 16, 
                              color:  Color(0xFFFF9933),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: screenWidth * 0.1),
                    // Circle and Name for Profile 2
                    Column(
                      children: [
                        CircleWithNameWidget(
                          assetPath: 'assets/images/pisces.png',
                          name: _person2Name!,
                          screenWidth: screenWidth,
                          onTap: () {
                            _showEditableProfileDialog2(context); // Function for the second profile
                          },
                          primaryColor: isEditing2? Color(0xFFFF9933): Color.fromARGB(255, 110, 110, 109),
                        ),
                        SizedBox(height: 8), // Space between name and 'Edit' text
                        GestureDetector(
                          onTap: () {
                            _showEditableProfileDialog2(context); // Function for the second profile
                          },
                          child: Text(
                            'Edit', // 'Edit' text below the name
                            style: TextStyle(
                              fontSize: 16, 
                              color:  Color(0xFFFF9933),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.08),
                Center(
                  child: Text(
                    'Compatibility Questions',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w100,
                      color: Color.fromARGB(255, 87, 86, 86),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator() // Show a loading indicator while fetching data
                      : CategoryDropdown(
                          // onTap: () => null,
                          inquiryType: 'compatibility',
                          categoryTypeId: 2,
                          onQuestionsFetched: (categoryId, questions) {
                            // Handle fetched questions
                          },
                          editedProfile2: isEditing2 ? getEditedProfile2() : null,
                          editedProfile: isEditing ? getEditedProfile() : null,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: BottomNavBar(screenWidth: screenWidth, screenHeight: screenHeight, currentPageIndex: 1),
  );
}



  

  void _showProfileDialog(BuildContext context, ProfileModel profile) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('User Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextRow('Name', profile.name),
          _buildTextRow('Date of Birth', profile.dob),
          _buildTextRow('Place of Birth', profile.cityId),
          _buildTextRow('Time of Birth', profile.tob),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    ),
  );
}
Widget _buildTextRow(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFFFF9933)),
      ),
      SizedBox(height: 5),
      Text(value), // Display the profile information
      SizedBox(height: 10),
    ],
  );
}

  void _showEditableProfileDialog(BuildContext context) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController cityIdController = TextEditingController();
  final TextEditingController tobController = TextEditingController();
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();  // To validate the form

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Check Compatibility of : ', style: TextStyle(fontSize: 16,fontFamily: 'Inter', fontWeight: FontWeight.w600,color: Color(0xFFFF9933))),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Name', nameController,  'This field required'),
            _buildTextField('Date of Birth (yyyy-mm-dd)', dobController,  'This field required'),
            _buildTextField('Place of Birth', cityIdController,  'This field required'),
            _buildTextField('Time of Birth (24 hr format hh:mm)', tobController,  'This field required'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
           child: Text(
                      'Cancel',
                      style: TextStyle(color: Color.fromARGB(255, 219, 35, 35)), // Grey color for Cancel
                    ),
                  ),
        TextButton(
          onPressed: () {
            isEditing=true;
            if (_formKey.currentState!.validate()) {
              setState(() {
                // Store the data entered in the dialog to the variables
                _editedName = nameController.text;
                _editedDob = dobController.text;
                _editedCityId = cityIdController.text;
                _editedTob = tobController.text;
              });

              // Print the edited details
              print('Edited Name: $_editedName');
              print('Edited Date of Birth: $_editedDob');
              print('Edited City ID: $_editedCityId');
              print('Edited Time of Birth: $_editedTob');
              Navigator.of(context).pop();
            }
          },
           child: Text(
                      'Save',
                      style: TextStyle(color: Colors.orange), // Orange color for Confirm
                    ),
                  ),
      ],
    ),
  );
}

// Save and navigate function remains unchanged
void _saveProfile(String editedName , String editedCityId, String editedDob, String editedTob) {
  this._editedName = editedName;
  this._editedCityId = editedCityId;
  this._editedDob = editedDob;
  this._editedTob = editedTob;

  nameController.text = _editedName ?? "";
  dobController.text = _editedDob ?? "";
  cityIdController.text = _editedCityId ?? "";
  tobController.text = _editedTob ?? "";
}

Map<String, dynamic> getEditedProfile() {
  return {
    'name': _editedName,
    'dob': _editedDob,
    'city_id': _editedCityId,
    'tob': _editedTob,
  };
}

// Refined text field with smaller size and minimal look
Widget _buildTextField(String label, TextEditingController controller, String validationMessage) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color:Color.fromARGB(255, 87, 86, 86), // Dark gray for a modern feel
          fontSize: 12,  // Smaller font size for label
          fontWeight: FontWeight.w400,
        ),
      ),
      SizedBox(height: 4),  // Reduced space between label and text field
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label.contains('Date of Birth') ? 'yyyy-mm-dd' : (label.contains('Time of Birth') ? 'hh:mm' : 'Enter here'),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),  // Smaller padding for text fields
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),  // Smaller rounded corners
            borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Color(0xFFFF9933), width: 1),  // Use the #FF9933 color for focus
          ),
        ),
        style: TextStyle(fontSize: 12), // Smaller font size for text input
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          // Date format validation (yyyy-mm-dd)
          if (label.contains('Date of Birth') && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
            return 'Please enter date in yyyy-mm-dd format';
          }
          // Time format validation (hh:mm)
          if (label.contains('Time of Birth') && !RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
            return 'Please enter time in 24 hr format hh:mm';
          }
          return null;
        },
      ),
      SizedBox(height: 12),  // Reduced space after text field
    ],
  );
}


  void _showEditableProfileDialog2(BuildContext context) {
  final TextEditingController name2Controller = TextEditingController();
  final TextEditingController dob2Controller = TextEditingController();
  final TextEditingController cityId2Controller = TextEditingController();
  final TextEditingController tob2Controller = TextEditingController();
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();  // To validate the form

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Check Compatibility with : ', style: TextStyle(fontSize: 16,fontFamily: 'Inter', fontWeight: FontWeight.w600,color: Color(0xFFFF9933))),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField2('Name', name2Controller, 'This field required'),
            _buildTextField2('Date of Birth (yyyy-mm-dd)', dob2Controller,  'This field required'),
            _buildTextField2('Place of Birth', cityId2Controller,  'This field required'),
            _buildTextField2('Time of Birth (24 hr format hh:mm)', tob2Controller,  'This field required'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
           child: Text(
                      'Cancel',
                      style: TextStyle(color: Color.fromARGB(255, 219, 35, 35)), // Grey color for Cancel
                    ),
                  ),
        TextButton(
          onPressed: () {
            isEditing2=true;
            if (_formKey.currentState!.validate()) {
              setState(() {
                // Store the data entered in the dialog to the variables
                _editedName2 = name2Controller.text;
                _editedDob2 = dob2Controller.text;
                _editedCityId2 = cityId2Controller.text;
                _editedTob2 = tob2Controller.text;
              });
               _person2Name = _editedName2 ;

              // Print the edited details
              print('Edited Name: $_editedName2');
              print('Edited Date of Birth: $_editedDob2');
              print('Edited City ID: $_editedCityId2');
              print('Edited Time of Birth: $_editedTob2');
              Navigator.of(context).pop();
            }
          },
           child: Text(
                      'Save',
                      style: TextStyle(color: Colors.orange), // Orange color for Confirm
                    ),
                  ),
      ],
    ),
  );
}

// Save and navigate function remains unchanged
void _saveProfile2(String editedName2 , String editedCityId2, String editedDob2, String editedTob2) {
  this._editedName2 = editedName2;
  this._editedCityId2 = editedCityId2;
  this._editedDob2 = editedDob2;
  this._editedTob2 = editedTob2;

  name2Controller.text = _editedName2 ?? "";
  dob2Controller.text = _editedDob2 ?? "";
  cityId2Controller.text = _editedCityId2 ?? "";
  tob2Controller.text = _editedTob2 ?? "";
}

Map<String, dynamic> getEditedProfile2() {
  return {
    'name': _editedName2,
    'dob': _editedDob2,
    'city_id': _editedCityId2,
    'tob': _editedTob2,
  };
}

// Refined text field with smaller size and minimal look
Widget _buildTextField2(String label, TextEditingController controller, String validationMessage) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color:Color.fromARGB(255, 87, 86, 86), // Dark gray for a modern feel
          fontSize: 12,  // Smaller font size for label
          fontWeight: FontWeight.w400,
        ),
      ),
      SizedBox(height: 4),  // Reduced space between label and text field
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label.contains('Date of Birth') ? 'yyyy-mm-dd' : (label.contains('Time of Birth') ? 'hh:mm' : 'Enter here'),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),  // Smaller padding for text fields
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),  // Smaller rounded corners
            borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Color(0xFFFF9933), width: 1),  // Use the #FF9933 color for focus
          ),
        ),
        style: TextStyle(fontSize: 12), // Smaller font size for text input
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          // Date format validation (yyyy-mm-dd)
          if (label.contains('Date of Birth') && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
            return 'Please enter date in yyyy-mm-dd format';
          }
          // Time format validation (hh:mm)
          if (label.contains('Time of Birth') && !RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
            return 'Please enter time in 24 hr format hh:mm';
          }
          return null;
        },
      ),
      SizedBox(height: 12),  // Reduced space after text field
    ],
  );
}

}

  

  

