import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/components/topnavbar.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/inbox/ui/chat_box_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  int? _selectedInquiryIndex; // To keep track of the selected inquiry
  final ScrollController _scrollController = ScrollController(); // ScrollController to manage scroll position
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  Future<List<dynamic>> _fetchInquiries() async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token');

      if (token == null) {
        throw Exception('Token is not available');
      }

      final url = 'http://145.223.23.200:3002/frontend/GuestInquiry/MyInquiries';

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

      final url = 'http://145.223.23.200:3002/frontend/GuestInquiry/MarkAsRead?inquiry_id=$inquiryId';

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

  // Function to build searchable inquiries list
  List<dynamic> _buildSearchableList(List<dynamic> inquiries) {
    return inquiries.where((inquiry) {
      String question = (inquiry['question'] ?? '').toLowerCase();
      String category = _getCategoryName(inquiry['category_type_id'] ?? 0).toLowerCase();
      String searchText = _searchText.toLowerCase();

      // Check if the search text is a substring of either the question or the category
      return question.contains(searchText) || category.contains(searchText);
    }).toList();
  }

  // Add a listener to update search text
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller when done
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  double screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    backgroundColor: Colors.white,
    body: Column(
      children: [
        // Custom TopNavBar replacing the default AppBar
        TopNavBar(
          title: 'Inbox',
          onLeftButtonPressed: () {
            // Define navigation logic, such as going back to Dashboard or any other action
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
          },
          leftIcon: Icons.arrow_back, // Set your preferred icon for the left side
        ),
        // Search bar section
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search inquiries...',
              prefixIcon: Icon(Icons.search, color: Color(0xFFFF9933)),
              filled: true,
              fillColor: const Color.fromARGB(255, 212, 210, 210),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // FutureBuilder for inquiries
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _fetchInquiries(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final inquiries = snapshot.data!;
                final filteredInquiries = _buildSearchableList(inquiries);

                if (filteredInquiries.isEmpty) {
                  return Center(child: Text('No inquiries found.'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: filteredInquiries.length,
                  itemBuilder: (context, index) {
                    final inquiry = filteredInquiries[index];
                    return _buildInquiryCard(inquiry, index, screenHeight, screenWidth);
                  },
                );
              } else {
                return Center(child: Text('No data available.'));
              }
            },
          ),
        ),
      ],
    ),
    // Custom BottomNavBar added as bottom navigation
    bottomNavigationBar: BottomNavBar(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      currentPageIndex: 3, // Assuming index 1 represents Inbox
    ),
  );
}


  Widget _buildInquiryCard(dynamic inquiry, int index, double screenHeight, double screenWidth) {
  bool isRead = inquiry['is_read'] ?? false;
  bool isReplied = inquiry['is_replied'] ?? false;
  int categoryTypeId = inquiry['category_type_id'] ?? 0;
  String categoryName = _getCategoryName(categoryTypeId);

  // Calculate responsive height using MediaQuery
  double cardHeight = screenHeight * 0.1; // 10% of the screen height
  double cardWidth = screenWidth * 0.9; // 90% of the screen width

  // Calculate responsive font sizes
  double titleFontSize = screenWidth * 0.03; // 3% of the screen width for title
  double subtitleFontSize = screenWidth * 0.025; // 2.5% of the screen width for subtitle

  // Calculate responsive icon sizes
  double iconSize = screenWidth * 0.04; // 4% of the screen width for the circle icon size
  double statusIconSize = screenWidth * 0.1; // 5% of the screen width for status icons

  return Card(
    elevation: 2.0,
    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenHeight * 0.01), // Margin based on screen size
    color: _selectedInquiryIndex == index ? Colors.blue[50] : Colors.white, // Highlight if selected
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15), // Add rounded corners
    ),
    child: Container(
      height: cardHeight, // Use responsive height
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Padding around the content
      child: Row( // Use Row to align items horizontally
        children: [
          // Circle icon in a Container to control size and vertical alignment
          Container(
            height: iconSize, // Height of the circle
            width: iconSize, // Width of the circle
            alignment: Alignment.center, // Center the icon within the container
            child: Icon(
              isRead ? null : Icons.circle,
              color: isRead ? null : Colors.orange,
              size: iconSize * 0.5, // Icon size (50% of the container size for a small circle)
            ),
          ),
          Expanded( // Use Expanded to take the remaining space for ListTile
            child: ListTile(
              contentPadding: EdgeInsets.all(5), // Remove default padding for a sleeker look
              title: Text(
                'Question: ${inquiry['question']} - $categoryName',
                style: TextStyle(
                  fontSize: titleFontSize, // Use responsive font size for title
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold, // Adjusting boldness based on read status
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Purchased on: ${inquiry['purchased_on']}',
                    style: TextStyle(fontSize: subtitleFontSize), // Use responsive font size for subtitle
                  ),
                  Text(
                    'Price: \$${inquiry['price']}',
                    style: TextStyle(fontSize: subtitleFontSize), // Use responsive font size for subtitle
                  ),
                ],
              ),
              trailing: Container(
                height: statusIconSize, // Height of the status icon
                width: statusIconSize, // Width of the status icon
                alignment: Alignment.center, // Center the icon within the container
                child: isReplied
                    ? Icon(Icons.done_all, color: Colors.blue, size: statusIconSize * 0.6) // Responsive size for done icon
                    : Icon(Icons.hourglass_empty, color: Colors.orange, size: statusIconSize * 0.6) // Responsive size for hourglass icon
              ),
              onTap: () async {
                await _markAsRead(inquiry['inquiry_id']);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatBoxPage(inquiry: inquiry),
                  ),
                );
                setState(() {
                  _selectedInquiryIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    ),
  );
}


}
