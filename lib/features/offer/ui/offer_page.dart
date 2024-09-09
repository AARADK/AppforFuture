import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/offer/model/offer_model.dart';
import 'package:flutter_application_1/features/ask_a_question/ui/ask_a_question_page.dart';
import 'package:flutter_application_1/features/offer/ui/offer_widget.dart'; // Import OfferWidget

class OfferPage extends StatelessWidget {
  final Offer offer;

  const OfferPage({required this.offer});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Offer Details'),
        backgroundColor: Color(0xFFFF9933),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use OfferWidget for displaying offer details
            OfferWidget(offer: offer),
            SizedBox(height: 8),
            // Offer description
            Text(
              offer.description ?? 'No Description Available',
              style: TextStyle(
                fontSize: screenWidth * 0.04, // Responsive font size
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Details Table',
              style: TextStyle(
                fontSize: screenWidth * 0.05, // Responsive font size
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFF9933).withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: DataTable(
                columnSpacing: screenWidth * 0.05, // Adjusted for better spacing
                headingRowHeight: 48, // Adjusted for better alignment
                dataRowHeight: 56, // Adjusted for better alignment
                columns: [
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'No. of Questions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Action',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                  ),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text(
                        'Horoscope',
                        style: TextStyle(fontSize: screenWidth * 0.038),
                      )),
                      DataCell(Text(
                        '${offer.horoscopeQuestionCount ?? 0}',
                        style: TextStyle(fontSize: screenWidth * 0.038),
                      )),
                      DataCell(
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AskQuestion(),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF9933),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              'Choose',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text(
                        'Compatibility',
                        style: TextStyle(fontSize: screenWidth * 0.038),
                      )),
                      DataCell(Text(
                        '${offer.compatibilityQuestionCount ?? 0}',
                        style: TextStyle(fontSize: screenWidth * 0.038),
                      )),
                      DataCell(
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AskQuestion(),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF9933),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              'Choose',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text(
                        'Auspicious',
                        style: TextStyle(fontSize: screenWidth * 0.038),
                      )),
                      DataCell(Text(
                        '1',
                        style: TextStyle(fontSize: screenWidth * 0.038),
                      )),
                      DataCell(
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AskQuestion(),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF9933),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              'Choose',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
