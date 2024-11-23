import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/components/buildcirclewithname.dart';
import 'package:flutter_application_1/components/categorydropdown.dart';
import 'package:flutter_application_1/components/topnavbar.dart';
import 'package:flutter_application_1/features/ask_a_question/repo/ask_a_question_repo.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/horoscope/model/horoscope_model.dart';
import 'package:flutter_application_1/features/horoscope/service/horoscope_service.dart';
import 'package:flutter_application_1/features/horoscope/repo/horoscope_repo.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart'; // Import the question model
import 'package:flutter_application_1/features/profile/model/profile_model.dart';
import 'package:flutter_application_1/features/profile/repo/profile_repo.dart';
import 'package:flutter_application_1/features/support/ui/support_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class HoroscopePage extends StatefulWidget {
  @override
  _HoroscopePageState createState() => _HoroscopePageState();
}

class _HoroscopePageState extends State<HoroscopePage> {
  final Color primaryColor = Color(0xFFFF9933);

  late Future<Horoscope> _horoscopeFuture;
  late Future<List<Question>>
      _questionsFuture; // Future for Horoscope questions
  final HoroscopeService _service = HoroscopeService(HoroscopeRepository());
  final AskQuestionRepository _askQuestionRepository =
      AskQuestionRepository(); // Instantiate the repository
  bool _isExpanded = false; // State variable for text expansion
  ProfileModel? _profile;
  Map<String, dynamic>? _horoscopeData;
  String? _person2Name = 'Person 2'; // Variable to store Person 2's name

  bool _isLoading = true;
  String? _errorMessage;
  // Add a DateTime variable to store the selected date
  DateTime? _selectedDate;
  DateTime? _horoscopeSelectedDate;

  String? _editedName = ProfileRepo().getName();
  String? _editedDob = '';
  String? _editedCityId = '';
  String? _editedTob = '';
  bool isEditing = false;

  Color _iconColor = Colors.black; // Initial color

  void _updateIconColor() {
    setState(() {
      _iconColor =
          _iconColor == Colors.black ? Color(0xFFFF9933) : Colors.black;
    });
  }

  // Method to show DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _horoscopeSelectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFFFF9933), // Customize the picker color
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _horoscopeSelectedDate) {
      setState(() {
        _horoscopeSelectedDate = picked;
      });
    }
  }

  void _showDateSelectionMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please select a date before proceeding.'),
        backgroundColor: Colors.red,
      ),
    );
  }

//For editable dialog 1
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController cityIdController = TextEditingController();
  final TextEditingController tobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Set the default date to the current date
    _fetchProfileData();
    _horoscopeFuture = _service.getHoroscope(_selectedDate!
        .toString()
        .split(' ')[0]); // Initialize with the current date
    _questionsFuture = _askQuestionRepository.fetchQuestionsByTypeId(1);
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
            _horoscopeData = responseData['data']['horoscope'];
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
          _errorMessage = 'Failed to load horoscope data';
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

    final String formattedDate = _horoscopeSelectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_horoscopeSelectedDate!)
        : 'Select Date';

    return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage()),
          );
          return false; // Prevent the default back button behavior
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: screenHeight *
                          0.4), // Increased bottom padding to accommodate questions
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Using TopNavWidget instead of SafeArea with custom AppBar
                      // Use TopNavBar here with correct arguments
                      TopNavBar(
                        title: 'Horoscope',
                        onLeftButtonPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DashboardPage()),
                          );
                        },
                        onRightButtonPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SupportPage()),
                          );
                        },
                        leftIcon: Icons.arrow_back, // Icon for the left side
                        rightIcon: Icons.help, // Icon for the right side
                      ),

                      SizedBox(height: screenHeight * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              CircleWithNameWidget(
                                assetPath: 'assets/images/virgo.png',
                                name: _editedName ??
                                    _profile?.name ??
                                    'no name available',
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
                              SizedBox(
                                  height: screenHeight *
                                      0.01), // Space between name and edit text
                              GestureDetector(
                                onTap: () {
                                  _showEditableProfileDialog(context);
                                },
                                child: Text(
                                  "Edit",
                                  style: TextStyle(
                                    color: Color(0xFFFF9933),
                                    fontSize: screenWidth * 0.035,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.04),
                      // Horoscope Description
                      FutureBuilder<Horoscope>(
                        future: _horoscopeFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Data is being generated, please wait....',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.040,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w100,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data == null ||
                              snapshot.data?.description == null ||
                              snapshot.data!.description.isEmpty) {
                            return Center(
                              child: Text(
                                'No horoscope data available at the moment.',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.040,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w100,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else {
                            final horoscope = snapshot.data!;
                            final description = horoscope.description;
                            final maxLines = _isExpanded
                                ? null
                                : 3; // Show full text if expanded, else limit to 3 lines

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.06),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    description,
                                    maxLines: maxLines,
                                    overflow: _isExpanded
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.040,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isExpanded =
                                            !_isExpanded; // Toggle text expansion
                                      });
                                    },
                                    child: Text(
                                      _isExpanded
                                          ? 'View Less'
                                          : 'View More', // Change button text based on state
                                      style: TextStyle(
                                        color: Color(0xFFFF9933),
                                        fontSize: screenWidth * 0.03,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Center(
                        child: Text(
                          'Horoscope Questions',
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
                                //  onTap: () => _selectDate(context),
                                inquiryType: 'Horoscope',
                                categoryTypeId: 1,
                                //  horoscopeFromDate: _horoscopeSelectedDate != null
                                //   ? formattedDate
                                //   : 'Please select a date', // Fallback message for unselected date
                                onQuestionsFetched: (categoryId, questions) {
                                  if (_horoscopeSelectedDate == null) {
                                    _showDateSelectionMessage();
                                  } else {
                                    // Handle fetched questions
                                  }
                                },
                                editedProfile:
                                    isEditing ? getEditedProfile() : null,
                              ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavBar(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              currentPageIndex: 0),
        ));
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
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF9933)),
        ),
        SizedBox(height: 5),
        Text(value), // Display the profile information
        SizedBox(height: 10),
      ],
    );
  }

 void _showEditableProfileDialog(BuildContext context) {
  // Initialize controllers with previously saved data
  final TextEditingController nameController =
      TextEditingController(text: _editedName);
  final TextEditingController dobController =
      TextEditingController(text: _editedDob);
  final TextEditingController cityIdController =
      TextEditingController(text: _editedCityId);
  final TextEditingController tobController =
      TextEditingController(text: _editedTob);

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // To validate the form

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Check Horoscope for:',
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          color: Color(0xFFFF9933),
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Name', nameController, 'This field required'),
            _buildTextField('Date of Birth (yyyy-mm-dd)', dobController,
                'This field required'),
            _buildTextField('Place of Birth', cityIdController,
                'This field required'),
            _buildTextField('Time of Birth (24 hr format hh:mm)', tobController,
                'This field required'),
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
            style: TextStyle(
              color: Color.fromARGB(255, 219, 35, 35),
            ), // Grey color for Cancel
          ),
        ),
        TextButton(
          onPressed: () {
            isEditing = true;
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
  void _saveProfile(String editedName, String editedCityId, String editedDob,
      String editedTob) {
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
  Widget _buildTextField(String label, TextEditingController controller,
      String validationMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color:
                Color.fromARGB(255, 87, 86, 86), // Dark gray for a modern feel
            fontSize: 12, // Smaller font size for label
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4), // Reduced space between label and text field
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label.contains('Date of Birth')
                ? ''
                : (label.contains('Time of Birth') ? '' : ''),
            contentPadding: EdgeInsets.symmetric(
                vertical: 8, horizontal: 12), // Smaller padding for text fields
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6), // Smaller rounded corners
              borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                  color: Color(0xFFFF9933),
                  width: 1), // Use the #FF9933 color for focus
            ),
          ),
          style: TextStyle(fontSize: 12), // Smaller font size for text input
          validator: (value) {
            if (value == null || value.isEmpty) {
              return validationMessage;
            }
            // Date format validation (yyyy-mm-dd)
            if (label.contains('Date of Birth') &&
                !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
              return 'Please enter date in yyyy-mm-dd format';
            }
            // Time format validation (hh:mm)
            if (label.contains('Time of Birth') &&
                !RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
              return 'Please enter time in 24 hr format hh:mm';
            }
            return null;
          },
        ),
        SizedBox(height: 12), // Reduced space after text field
      ],
    );
  }
}
