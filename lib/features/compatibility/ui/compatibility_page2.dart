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

  }

  Future<void> _fetchProfileData() async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token');
      String url = 'http://45.117.153.217:3001/frontend/Guests/Get';

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
                  title: 'Compatibility',
                  onLeftButtonPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CompatibilityPage()),
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
                          name: _editedName?? _profile?.name ?? 'no name available',
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
                          left:70,
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
                    SizedBox(width: screenWidth * 0.1),
                    // Circle and Edit Icon for Person 2
                    Stack(
                      children: [
                        CircleWithNameWidget(
                          assetPath: 'assets/images/pisces.png',
                          name: _person2Name!,
                          screenWidth: screenWidth,
                          onTap: () {
                            _showEditableProfileDialog2(context);
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
                                  _showEditableProfileDialog2(context);
                                }
                              },
                            ),
                        ),
                      ],
                    ),
                  ],
                ),
                // SizedBox(height: screenHeight * 0.02),
                // _isLoading
                //     ? Center(child: CircularProgressIndicator())
                //     : _errorMessage != null
                //         ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
                //         : Padding(
                //             padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: _compatibilityData?.entries.map((entry) {
                //                 return _buildCompatibilityRow(entry.key, entry.value);
                //               }).toList() ?? [],
                //             ),
                //           ),
                SizedBox(height: screenHeight * 0.02),
                                Center(
                  child: _isLoading
                    ? const CircularProgressIndicator() // Show a loading indicator while fetching data
                    : CategoryDropdown(
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
        CustomButton(
          buttonText: 'Submit',
          onPressed: () {
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

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Enter details '),
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

  nameController.text = _editedName?? "";
  dobController.text = _editedDob?? "";
  cityIdController.text = _editedCityId?? "";
  tobController.text = _editedTob?? "";
  }

 Map<String, dynamic> getEditedProfile() {
    return {
     'name': _editedName,
      'dob': _editedDob,
      'city_id': _editedCityId,
      'tob': _editedTob,
    };
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

  void _showEditableProfileDialog2(BuildContext context) {

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Enter details 2'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField2('Name', name2Controller),
          _buildTextField2('Date of Birth', dob2Controller),
          _buildTextField2('Place of Birth', cityId2Controller),
          _buildTextField2('Time of Birth', tob2Controller),
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
             isEditing2 = true;
            


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
          },
          child: Text('Save'),
        ),
      ],
    ),
  );
}

// Assuming you have a method to handle saving the profile and navigating
void _saveProfile2(String editedName2 , String editedCityId2, String editedDob2, String editedTob2) {
    // Save the edited details
    // You might also want to update the class variables here
    this._editedName2 = editedName2;
    this._editedCityId2 = editedCityId2;
    this._editedDob2 = editedDob2;
    this._editedTob2 = editedTob2;

    
  name2Controller.text = _editedName2?? "";
  dob2Controller.text = _editedDob2?? "";
  cityId2Controller.text = _editedCityId2?? "";
  tob2Controller.text = _editedTob2?? "";
  }

 Map<String, dynamic> getEditedProfile2() {
    return {
     'name': _editedName2,
      'dob': _editedDob2,
      'city_id': _editedCityId2,
      'tob': _editedTob2,
    };
  }

Widget _buildTextField2(String label, TextEditingController controller) {
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

Widget _buildCompatibilityRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Text(value.toString(), style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

  

  

