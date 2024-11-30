import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBoxPage extends StatelessWidget {
  final Map<String, dynamic>? inquiry;

  ChatBoxPage({this.inquiry});

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
        return 'Unknown Category';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isRead = inquiry?['is_read'] ?? false;
    bool isReplied = inquiry?['is_replied'] ?? false;
    String? finalReading = inquiry?['final_reading'];
    String? finalReadingDate = inquiry?['final_reading_on'];
    int categoryTypeId = inquiry?['category_type_id'] ?? 0;
    String categoryName = _getCategoryName(categoryTypeId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // User's Inquiry Details including profiles
              Align(
                alignment: Alignment.centerLeft,
                child: _buildUserInquiry(inquiry, categoryName, isRead),
              ),
              SizedBox(height: 20),

              // Backend's Reply with Star Rating
              if (isReplied && finalReading != null && finalReading.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildMessageBubble(
                    'Reply:',
                    finalReading,
                    Colors.blue.shade200,
                    finalReadingDate != null
                        ? DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(finalReadingDate))
                        : 'Date not available',
                    const Color.fromARGB(255, 6, 22, 35),
                  ),
                )
              else
                Center(child: Text('Awaiting reply...')),
            ],
          ),
        ),
      ),
    );
  }

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
          Text(
              'Purchased on: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(inquiry['purchased_on']))}'),
          if (isRead)
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text('Seen',
                  style: TextStyle(
                      color: Colors.green, fontStyle: FontStyle.italic)),
            ),
          SizedBox(height: 10),

          // Profiles included as part of the inquiry
          _buildProfiles(inquiry),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      String title, String message, Color color, String date, Color textColor,
      {String? additionalInfo, bool isRead = false}) {
    int selectedStars = 3; // Default rating

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
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
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: textColor)),
              Text(message, style: TextStyle(color: textColor)),
              SizedBox(height: 5),
              Text(date,
                  style: TextStyle(
                      fontSize: 12, color: textColor.withOpacity(0.6))),
              if (isRead)
                Text(
                  'Seen',
                  style: TextStyle(
                      color: Colors.green,
                      fontStyle: FontStyle.italic,
                      fontSize: 12),
                ),
              SizedBox(height: 10),

              // Star Rating Widget
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedStars = index + 1;
                      });
                      print('Star ${index + 1} tapped');
                    },
                    child: Icon(
                      Icons.star,
                      color: index < selectedStars
                          ? Color.fromARGB(255, 7, 38, 88)
                          : Colors.grey,
                      size: 20,
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfiles(dynamic inquiry) {
    if (inquiry['profile1'] != null && inquiry['profile2'] != null) {
      return IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _buildProfileCard(inquiry['profile1'])),
            SizedBox(width: 10),
            Expanded(child: _buildProfileCard(inquiry['profile2'])),
          ],
        ),
      );
    } else if (inquiry['profile1'] != null) {
      return Center(child: _buildProfileCard(inquiry['profile1']));
    } else if (inquiry['profile2'] != null) {
      return Center(child: _buildProfileCard(inquiry['profile2']));
    } else {
      return SizedBox();
    }
  }

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
              Icon(Icons.account_circle,
                  color: Colors.orange.shade600, size: 24),
              SizedBox(width: 5),
              Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          Divider(color: Colors.orange.shade300),
          Text('Name: ${profile['name']}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('City: ${profile['city_id']}'),
          Text('DOB: ${profile['dob']}'),
          Text('TOB: ${profile['tob']}'),
        ],
      ),
    );
  }
}
