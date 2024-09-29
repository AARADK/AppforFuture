import 'package:flutter/material.dart';

class ChatBoxPage extends StatelessWidget {
  final dynamic inquiry;

  ChatBoxPage({required this.inquiry});

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
    int categoryTypeId = inquiry['category_type_id'] ?? 0;
    String categoryName = _getCategoryName(categoryTypeId);
    bool isReplied = inquiry['is_replied'] ?? false;
    bool isRead = inquiry['is_read'] ?? false;
    String? finalReading = inquiry['final_reading']; // Get reply content if available

    return Scaffold(
      appBar: AppBar(
        title: Text('Inquiry Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Inquiry from the user on the left side
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You asked:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    Text(
                      inquiry['question'] ?? 'No question provided',
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Purchased on: ${inquiry['purchased_on']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (isRead)
                      Text(
                        'Seen',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      )
                    else
                      Text(
                        'Not Seen',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            // Backend's reply on the right side
            if (isReplied && finalReading != null) // Show reply only if replied and not null
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Astrologer replied:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      Text(
                        finalReading,
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Reply received on: ${inquiry['final_reading_on'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            if (!isReplied)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Awaiting reply...',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
