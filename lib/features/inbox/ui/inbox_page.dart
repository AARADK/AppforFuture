import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  Future<List<dynamic>> _fetchInquiries() async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token');

      if (token == null) {
        throw Exception('Token is not available');
      }

      final url = 'http://52.66.24.172:7001/frontend/GuestInquiry/MyInquiries'; // Replace with actual URL

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
              itemCount: inquiries.length,
              itemBuilder: (context, index) {
                final inquiry = inquiries[index];
                return _buildInquiryCard(inquiry);
              },
            );
          } else {
            return Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }

  Widget _buildInquiryCard(dynamic inquiry) {
    bool isRead = inquiry['is_read'] ?? false;
    bool isReplied = inquiry['is_replied'] ?? false;

    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(
          isRead ? Icons.mark_email_read : Icons.mark_email_unread,
          color: isRead ? Colors.green : Colors.red,
        ),
        title: Text(
          inquiry['question'],
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
        onTap: () {
          // Navigate to detailed inquiry view if needed
          _showInquiryDetails(inquiry);
        },
      ),
    );
  }

  void _showInquiryDetails(dynamic inquiry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Inquiry Details'),
        content: Text('Question: ${inquiry['question']}\n'
            'Purchased On: ${inquiry['purchased_on']}\n'
            'Price: \$${inquiry['price']}\n'
            'Is Replied: ${inquiry['is_replied']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
