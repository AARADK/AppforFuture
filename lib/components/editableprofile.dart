import 'package:flutter/material.dart';

class EditableProfileDialog {
  static void showEditableProfileDialog(
    BuildContext context, {
    required Function(String, String, String, String) onSave,
  }) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController dobController = TextEditingController();
    final TextEditingController cityIdController = TextEditingController();
    final TextEditingController tobController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Set dialog background to pure white
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Center(
          child: Text(
            'Check Horoscope for:',
            style: TextStyle(
              color: Color(0xFFFF9933),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Name', nameController),
              SizedBox(height: 6), // Reduced spacing
              _buildTextField('Date of Birth', dobController),
              SizedBox(height: 6),
              _buildTextField('Place of Birth', cityIdController),
              SizedBox(height: 6),
              _buildTextField('Time of Birth', tobController),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Close',
                  style: TextStyle(color: Colors.black87, fontSize: 12),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF9933),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {
                  onSave(
                    nameController.text,
                    cityIdController.text,
                    dobController.text,
                    tobController.text,
                  );
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFFFF9933),
            fontSize: 12, // Smaller label font
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4), // Reduced spacing
        Container(
          height: 36, // Compact height for the text field container
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 12), // Smaller input text
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Compact padding
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFFFF9933)),
              ),
              filled: true,
              fillColor: Colors.white, // Clear white background
            ),
          ),
        ),
      ],
    );
  }
}
