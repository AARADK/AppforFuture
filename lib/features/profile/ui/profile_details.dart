import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/updateprofile/update_profile_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileDetails extends StatefulWidget {
  @override
  _ProfileDetailsState createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  bool _isLoading = true;
  bool _isEditing = false;
  String? _errorMessage;
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _guestProfileData;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _tobController = TextEditingController();

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
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
            _profileData = responseData['data']['item'];
            _guestProfileData = _profileData!['guest_profile'];
            _nameController.text = _profileData!['name'] ?? '';
            _locationController.text = _profileData!['city_id'] ?? '';
            _dobController.text = _profileData!['dob'] ?? '';
            _tobController.text = _profileData!['tob'] ?? '';
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
          _errorMessage = 'Failed to load profile data';
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

  void _updateProfile() async {
    final updateProfileService = UpdateProfileService();

    bool success = await updateProfileService.updateProfile(
      _nameController.text,
      _locationController.text,
      _dobController.text,
      _tobController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
      _fetchProfileData();
      setState(() {
        _isEditing = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double padding = mediaQuery.size.width * 0.05; // 5% of screen width
    final double spacing = mediaQuery.size.height * 0.02; // 2% of screen height
    final double fontSize = mediaQuery.size.width * 0.04; // 4% of screen width
    final double buttonPadding = mediaQuery.size.width * 0.1; // 10% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFFF9933),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(padding),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red, fontSize: fontSize)))
                : _buildProfileUI(fontSize, spacing, buttonPadding),
      ),
    );
  }

  Widget _buildProfileUI(double fontSize, double spacing, double buttonPadding) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Name', _nameController, Icons.person, _isEditing, fontSize),
          SizedBox(height: spacing),
          _buildTextField('City ID', _locationController, Icons.location_city, _isEditing, fontSize),
          SizedBox(height: spacing),
          _buildTextField('Date of Birth (YYYY-MM-DD)', _dobController, Icons.cake, _isEditing, fontSize),
          SizedBox(height: spacing),
          _buildTextField('Time of Birth (HH:mm)', _tobController, Icons.access_time, _isEditing, fontSize),
          SizedBox(height: spacing * 1.5),
          _guestProfileData == null
              ? Center(child: Text('Profile is being generated...', style: TextStyle(color: Colors.orange, fontSize: fontSize)))
              : _buildGuestProfileUI(fontSize, spacing),
          SizedBox(height: spacing * 1.5),
          _isEditing
              ? Center(
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF9933),
                      padding: EdgeInsets.symmetric(horizontal: buttonPadding, vertical: spacing),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('Update Profile', style: TextStyle(fontSize: fontSize)),
                  ),
                )
              : Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF9933),
                      padding: EdgeInsets.symmetric(horizontal: buttonPadding, vertical: spacing),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('Edit Profile', style: TextStyle(fontSize: fontSize)),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildGuestProfileUI(double fontSize, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guest Profile Details:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
        ),
        SizedBox(height: spacing / 2),

        // Basic Description
        _buildGuestProfileDetail(
          label: 'Basic Description',
          value: _guestProfileData!['basic_description'] ?? '',
          fontSize: fontSize,
          isExpandable: true, // Indicating that this field is expandable
        ),

        // Lucky Color
        _buildGuestProfileDetail(
          label: 'Lucky Color',
          value: _guestProfileData!['lucky_color'] ?? '',
          fontSize: fontSize,
        ),

        // Lucky Gem
        _buildGuestProfileDetail(
          label: 'Lucky Gem',
          value: _guestProfileData!['lucky_gem'] ?? '',
          fontSize: fontSize,
        ),

        // Lucky Number
        _buildGuestProfileDetail(
          label: 'Lucky Number',
          value: _guestProfileData!['lucky_number'] ?? '',
          fontSize: fontSize,
        ),

        // Rashi Name
        _buildGuestProfileDetail(
          label: 'Rashi Name',
          value: _guestProfileData!['rashi_name'] ?? '',
          fontSize: fontSize,
        ),

        // Compatibility
        _buildGuestProfileDetail(
          label: 'Compatibility',
          value: _guestProfileData!['compatibility_description'] ?? '',
          fontSize: fontSize,
        ),
      ],
    );
  }

  Widget _buildGuestProfileDetail({
    required String label,
    required String value,
    required double fontSize,
    bool isExpandable = false,
  }) {
    if (isExpandable) {
      final int maxLength = 100; // Define the maximum number of characters before truncating
      bool isTruncated = value.length > maxLength && !_isExpanded;

      return Padding(
        padding: EdgeInsets.symmetric(vertical: fontSize * 0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, color: Color(0xFFFF9933)),
                ),
                Expanded(
                  child: Text(
                    isTruncated ? '${value.substring(0, maxLength)}...' : value,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              ],
            ),
            if (isTruncated || _isExpanded)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? 'View Less' : 'View More',
                  style: TextStyle(
                    fontSize: fontSize * 0.9,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: fontSize * 0.4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, color: Color(0xFFFF9933)),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon, bool isEditable, double fontSize) {
    return TextField(
      controller: controller,
      enabled: isEditable,
      style: TextStyle(fontSize: fontSize),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: fontSize),
        prefixIcon: Icon(icon, size: fontSize * 1.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
