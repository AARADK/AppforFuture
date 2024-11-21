import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBoxPage extends StatelessWidget {
  final dynamic inquiry;

  ChatBoxPage({required this.inquiry});

  String _getCategoryName(int categoryTypeId) {
    switch (categoryTypeId) {
      case 1:
        return 'Horoscope';
      case 2:
        return 'Compatibility';
      case 3:
        return 'Auspicious Time';
      case 4:
        return 'Kundali';
      case 5:
        return 'Support';
      case 6:
        return 'Ask a Question';
      default:
        return 'Unknown Category'; // Handle any unknown categories
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isRead = inquiry['is_read'] ?? false;
    bool isReplied = inquiry['is_replied'] ?? false;
    String? finalReading = inquiry['final_reading'];
    int categoryTypeId = inquiry['category_type_id'] ?? 0;
    String categoryName = _getCategoryName(categoryTypeId);

    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // User's Inquiry Details including profiles
            Align(
              alignment: Alignment.centerLeft,
              child: _buildUserInquiry(inquiry, categoryName, isRead),
            ),

            SizedBox(height: 20),

            // Backend's Reply
            if (isReplied && finalReading != null)
              Align(
                alignment: Alignment.centerRight,
                child: _buildMessageBubble(
                  'Reply:',
                  finalReading,
                  Colors.blue.shade200,
                  DateFormat('yyyy-MM-dd').format(DateTime.parse(inquiry['final_reading_on'])),
                  Colors.blue,
                ),
              )
            else
              Center(child: Text('Awaiting reply...')),
          ],
        ),
      ),
    );
  }

  // Method to build user's inquiry details including profile cards
  Widget _buildUserInquiry(dynamic inquiry, String categoryName, bool isRead) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 240, 216, 192),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(inquiry['question'] ?? 'No question provided'),
          SizedBox(height: 5),
          Text('Category: $categoryName'),
          Text('Price: \$${inquiry['price']}'),
          Text('Purchased on: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(inquiry['purchased_on']))}'),
          if (isRead)
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text('Seen', style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic)),
            ),
          SizedBox(height: 10),

          // Profiles included as part of the inquiry
          _buildProfiles(inquiry),
        ],
      ),
    );
  }

  // Method to build a message bubble
  Widget _buildMessageBubble(String title, String message, Color color, String date, Color textColor,
      {String? additionalInfo, bool isRead = false}) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          Text(message, style: TextStyle(color: textColor)),
          SizedBox(height: 5),
          Text(date, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6))),
          if (isRead)
            Text(
              'Seen',
              style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic, fontSize: 12),
            ),
        ],
      ),
    );
  }

  // Method to build profiles dynamically
  Widget _buildProfiles(dynamic inquiry) {
    if (inquiry['profile1'] != null && inquiry['profile2'] != null) {
      return Row(
        children: [
          Expanded(child: _buildProfileCard(inquiry['profile1'])),
          SizedBox(width: 10),
          Expanded(child: _buildProfileCard(inquiry['profile2'])),
        ],
      );
    } else if (inquiry['profile1'] != null) {
      return Center(child: _buildProfileCard(inquiry['profile1']));
    } else if (inquiry['profile2'] != null) {
      return Center(child: _buildProfileCard(inquiry['profile2']));
    } else {
      return SizedBox();
    }
  }

  // Method to build each profile card with consistent styling
  Widget _buildProfileCard(dynamic profile) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_circle, color: Colors.orange.shade600, size: 24),
              SizedBox(width: 5),
              Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          Divider(color: Colors.orange.shade300),
          Text('Name: ${profile['name']}', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('City: ${profile['city_id']}'),
          Text('DOB: ${profile['dob']}'),
          Text('TOB: ${profile['tob']}'),
        ],
      ),
    );
  }
}
