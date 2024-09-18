import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/components/buildcirclewithname.dart';
import 'package:flutter_application_1/components/categorydropdown.dart';
import 'package:flutter_application_1/components/custom_button.dart';
import 'package:flutter_application_1/components/questionlistwidget.dart';
import 'package:flutter_application_1/components/topnavbar.dart';
import 'package:flutter_application_1/features/ask_a_question/repo/ask_a_question_repo.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/horoscope/model/horoscope_model.dart';
import 'package:flutter_application_1/features/horoscope/service/horoscope_service.dart';
import 'package:flutter_application_1/features/inbox/ui/inbox_page.dart';
import 'package:flutter_application_1/features/payment/ui/payment_page.dart';
import 'package:flutter_application_1/features/horoscope/repo/horoscope_repo.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart'; // Import the question model
import 'package:flutter_application_1/features/profile/model/profile_model.dart';
import 'package:flutter_application_1/features/profile/repo/profile_repo.dart';
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
  late Future<List<Question>> _questionsFuture; // Future for Horoscope questions
  final HoroscopeService _service = HoroscopeService(HoroscopeRepository());
  final AskQuestionRepository _askQuestionRepository = AskQuestionRepository(); // Instantiate the repository
  bool _isExpanded = false; // State variable for text expansion
  ProfileModel? _profile;
  Map<String, dynamic>? _horoscopeData;
  String? _person2Name = 'Person 2'; // Variable to store Person 2's name

  bool _isLoading = true;
  String? _errorMessage;
  // Add a DateTime variable to store the selected date
  DateTime? _selectedDate;
  DateTimeRange? selectedDateRange;
  String? _editedName = '';
String? _editedDob = '';
String? _editedCityId = '';
String? _editedTob = '';
bool isEditing = false;

Color _iconColor = Colors.black; // Initial color

  void _updateIconColor() {
    setState(() {
      _iconColor = _iconColor == Colors.black ? Color(0xFFFF9933) : Colors.black;
    });
  }




  

  // Method to show DateRangePicker
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange,
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
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }
  
  
 @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Set the default date to the current date
    _fetchProfileData();
    _horoscopeFuture = _service.getHoroscope(_selectedDate!.toString().split(' ')[0]); // Initialize with the current date
    _questionsFuture = _askQuestionRepository.fetchQuestionsByTypeId(1);

  }

  
  Future<void> _fetchProfileData() async {
  try {
    final box = Hive.box('settings');
    String? token = await box.get('token');
    String url = 'http://52.66.24.172:7001/frontend/Guests/Get';

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
  
  

  // Format selected date range to "YYYY-MM-DD"
    final String formattedStartDate = selectedDateRange != null
        ? DateFormat('yyyy-MM-dd').format(selectedDateRange!.start)
        : 'Start date';
    final String formattedEndDate = selectedDateRange != null
        ? DateFormat('yyyy-MM-dd').format(selectedDateRange!.end)
        : 'End date';

  return WillPopScope(
    onWillPop: () async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
      return false; // Prevent the default back button behavior
    },
    child:Scaffold(
    backgroundColor: Colors.white,
    body: Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.4), // Increased bottom padding to accommodate questions
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
                      MaterialPageRoute(builder: (context) => DashboardPage()),
                    );
                  },
                  leftIcon: Icons.done, // Optional: Change to menu if you want
                ),
                SizedBox(height: screenHeight * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circle and Edit Icon for Profile
                    Stack(
                      children: [
                        CircleWithNameWidget(
                          assetPath: 'assets/images/virgo.png',
                          name: _profile?.name ?? _editedName?? 'no name available',
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
                        Positioned(
                            left: 70,
                            right: 0,
                            top: 8,
                            child: IconButton(
                              icon: Icon(Icons.edit, color: _iconColor),
                              onPressed: () {
                                _updateIconColor();
                                if (_profile != null) {
                                  _showEditableProfileDialog(context);
                                }
                              },
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                    } else if (!snapshot.hasData || snapshot.data == null || snapshot.data?.description == null || snapshot.data!.description.isEmpty) {
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
                      final maxLines = _isExpanded ? null : 3; // Show full text if expanded, else limit to 3 lines

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              description,
                              maxLines: maxLines ,
                              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
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
                                  _isExpanded = !_isExpanded; // Toggle text expansion
                                });
                              },
                              child: Text(
                                _isExpanded ? 'View Less' : 'View More', // Change button text based on state
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
                  child: _isLoading
                    ? const CircularProgressIndicator() // Show a loading indicator while fetching data
                    : CategoryDropdown(
                       inquiryType: 'Horoscope',
                        categoryTypeId: 1,
                        onQuestionsFetched: (categoryId, questions) {
                          // Handle fetched questions
                        },
                        // Conditionally pass editedProfile based on isEditing flag
                        editedProfile: isEditing ? getEditedProfile() : null,
                    ),
                ),

                                SizedBox(height: screenHeight * 0.02),

                   // Add Date selector button
                  Center(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Select Date range',
          style: TextStyle(
            color: Color(0xFFFF9933),
            fontSize: screenWidth * 0.04,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),
                   SizedBox(height: screenHeight * 0.01),
                          
                         // Display the selected date range
Center(
  child: GestureDetector(
    onTap: () => _selectDateRange(context),
    child: Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.008, // Reduced padding for a smaller container
        horizontal: screenWidth * 0.04, // Reduced horizontal padding
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xFFFF9933),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        '$formattedStartDate to $formattedEndDate',
        style: TextStyle(
          color:  Color(0xFFFF9933),
          fontSize: screenWidth * 0.035, // Reduced font size
          fontFamily: 'Inter',
        ),
      ),
    ),
  ),
)
                ],
              ),
            ),
          ),
          // Place the CustomButton above the bottom navigation bar
          CustomButton(
            buttonText: 'Submit',
            onPressed: () {
            // Define your button action
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentPage()),
            );
          },
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),
        ],
      ),
      
      bottomNavigationBar: BottomNavBar(screenWidth: screenWidth, screenHeight: screenHeight,currentPageIndex: 1), 
  )
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

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Enter details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Name', nameController),
          _buildTextField('Date of Birth', dobController),
          _buildTextField('Place of Birth', cityIdController),
          _buildTextField('Time of Birth', tobController),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
        TextButton(
          onPressed: () {
            isEditing = true;
            _editedName = _editedName;

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
          },
          child: Text('Save'),
        ),
      ],
    ),
  );
}

// Assuming you have a method to handle saving the profile and navigating
void _saveProfile(String editedName , String editedCityId, String editedDob, String editedTob) {
    // Save the edited details
    // You might also want to update the class variables here
    this._editedName = editedName;
    this._editedCityId = editedCityId;
    this._editedDob = editedDob;
    this._editedTob = editedTob;
  }

 Map<String, dynamic> getEditedProfile() {
    return {
     'name': _editedName,
      'dob': _editedDob,
      'city_id': _editedCityId,
      'tob': _editedTob,
    };
  }
}

Widget _buildTextField(String label, TextEditingController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: Color(0xFFFF9933), // Set the label color to #FF9933
        ),
      ),
      SizedBox(height: 5),
      TextField(controller: controller),
    ],
  );
}

