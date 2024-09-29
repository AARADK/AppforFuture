import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  int? _selectedInquiryIndex; // To keep track of the selected inquiry
  final ScrollController _scrollController = ScrollController(); // ScrollController to manage scroll position

  Future<List<dynamic>> _fetchInquiries() async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token');

      if (token == null) {
        throw Exception('Token is not available');
      }

      final url = 'http://52.66.24.172:7001/frontend/GuestInquiry/MyInquiries';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['error_code'] == "0") {
          var inquiries = responseData['data']['inquiries'];
          if (inquiries is List) {
            return inquiries;
          } else {
            throw Exception('Unexpected response format: inquiries is not a list');
          }
        } else {
          throw Exception('Error: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load inquiries: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching inquiries: $e');
      return [];
    }
  }

  Future<void> _markAsRead(String inquiryId) async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token');

      if (token == null) {
        throw Exception('Token is not available');
      }

      final url =
          'http://52.66.24.172:7001/frontend/GuestInquiry/MarkAsRead?inquiry_id=$inquiryId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['error_code'] == "0") {
          print('Marked as read successfully');
        } else {
          throw Exception('Error: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to mark as read: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking inquiry as read: $e');
    }
  }

  // Function to map category_type_id to category names
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
      default:
        return 'Unknown Category'; // Handle any unknown categories
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchInquiries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final inquiries = snapshot.data!;
            if (inquiries.isEmpty) {
              return Center(child: Text('No inquiries found.'));
            }

            return ListView.builder(
              controller: _scrollController, // Attach the ScrollController here
              itemCount: inquiries.length,
              itemBuilder: (context, index) {
                final inquiry = inquiries[index];
                return _buildInquiryCard(inquiry, index);
              },
            );
          } else {
            return Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }

  Widget _buildInquiryCard(dynamic inquiry, int index) {
    bool isRead = inquiry['is_read'] ?? false;
    bool isReplied = inquiry['is_replied'] ?? false;
    int categoryTypeId = inquiry['category_type_id'] ?? 0;
    String categoryName = _getCategoryName(categoryTypeId);

    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: _selectedInquiryIndex == index ? Colors.blue[50] : Colors.white, // Highlight if selected
      child: ListTile(
        leading: Icon(
          isRead ? Icons.mark_email_read : Icons.mark_email_unread,
          color: isRead ? Colors.green : Colors.red,
        ),
        title: Text(
          'Question: ${inquiry['question']} - $categoryName\n',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Purchased on: ${inquiry['purchased_on']}'),
            Text('Price: \$${inquiry['price']}'),
          ],
        ),
        trailing: isReplied
            ? Icon(Icons.done_all, color: Colors.blue)
            : Icon(Icons.hourglass_empty, color: Colors.orange),
        onTap: () async {
          await _markAsRead(inquiry['inquiry_id']);
          setState(() {
            _selectedInquiryIndex = index; // Set selected inquiry index
          });
          _showChatBox(inquiry);
        },
      ),
    );
  }

 void _showChatBox(dynamic inquiry) {
  bool isRead = inquiry['is_read'] ?? false;
  bool isReplied = inquiry['is_replied'] ?? false;
  String? finalReading = inquiry['final_reading'];

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.all(10),
      content: SizedBox(
        width: 400,
        height: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left Side: User's Inquiry Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inquiry['question'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Price: \$${inquiry['price']}',
                          ),
                          Text(
                            'Purchased on: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(inquiry['purchased_on']))}',
                          ),
                          SizedBox(height: 5),

                          // Add the profiles dynamically here
                          _buildProfiles(inquiry),
                          
                          SizedBox(height: 5),
                          if (isRead)
                            Text(
                              'Seen',
                              style: TextStyle(
                                color: Colors.green,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Right Side: Backend's Reply
            if (isReplied && finalReading != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reply:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(finalReading),
                            SizedBox(height: 5),
                            Text(
                              'Replied on: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(inquiry['final_reading_on']))}',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Center(child: Text('Awaiting reply...')),
          ],
        ),
      ),
    ),
  ).then((_) {
    // Ensures the state updates are done after the dialog is closed
    // setState(() {
    //   _selectedInquiryIndex = null; // Reset selected inquiry index after dialog
    // });
  });
}

// Method to build profiles dynamically
Widget _buildProfiles(dynamic inquiry) {
  if (inquiry['profile1'] != null && inquiry['profile2'] != null) {
    return Row(
      children: [
        Expanded(child: _buildProfileCard(inquiry['profile1'])),
        SizedBox(width: 10), // Space between cards
        Expanded(child: _buildProfileCard(inquiry['profile2'])),
      ],
    );
  } else if (inquiry['profile1'] != null) {
    return Center(child: _buildProfileCard(inquiry['profile1']));
  } else if (inquiry['profile2'] != null) {
    return Center(child: _buildProfileCard(inquiry['profile2']));
  } else {
    return SizedBox(); // Return an empty widget if no profiles
  }
}

// Method to build each profile card
Widget _buildProfileCard(dynamic profile) {
  return Card(
    elevation: 2.0,
    margin: EdgeInsets.symmetric(vertical: 5),
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name: ${profile['name']}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('City: ${profile['city_id']}'),
          Text('DOB: ${profile['dob']}'),
          Text('TOB: ${profile['tob']}'),
        ],
      ),
    ),
  );
}
}