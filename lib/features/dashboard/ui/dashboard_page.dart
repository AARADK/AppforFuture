import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/features/ask_a_question/ui/ask_a_question_page.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/dashboard/model/dashboard_model.dart';
import 'package:flutter_application_1/features/dashboard/service/dashboard_service.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/inbox/ui/inbox_page.dart';
import 'package:flutter_application_1/features/menu/ui/menu_page.dart';
import 'package:flutter_application_1/features/offer/model/offer_model.dart';
import 'package:flutter_application_1/features/offer/service/offer_service.dart';
import 'package:flutter_application_1/features/offer/ui/alloffers.dart';
import 'package:flutter_application_1/features/offer/ui/offer_widget.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<DashboardPage> {
  bool _isMenuOpen = false;
  late Future<DashboardData> _dashboardDataFuture;
  late Future<List<Offer>> _offersFuture; // Added for offers data

  @override
  void initState() {
    super.initState();
    
    // Get the current date
    final today = DateTime.now();
    final formattedDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Fetch dashboard data for the current date
    _dashboardDataFuture = DashboardService().getDashboardData(formattedDate);
    _offersFuture = OfferService().getTopOffers(); // Fetch offers data
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openMenu() {
    setState(() {
      _isMenuOpen = true;
    });
  }

  void _closeMenu() {
    setState(() {
      _isMenuOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double iconSize = size.width * 0.12;
    final double circleSize = size.width * 0.22;
    final double buttonWidth = size.width * 0.8;
    final double buttonHeight = size.height * 0.07;
     final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_isMenuOpen) {
                _closeMenu();
              }
            },
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx < -6 && _isMenuOpen) {
                _closeMenu(); // Close the menu on left swipe if it's open
              } else if (details.delta.dx > 6 && !_isMenuOpen) {
                _openMenu(); // Open the menu on right swipe if it's closed
              }
            },
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _openMenu(); // Open the menu when the menu icon is tapped
                                  },
                                  child: Container(
                                    width: iconSize,
                                    height: iconSize,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Color(0xFFFF9933)),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(Icons.menu, color: Color(0xFFFF9933)),
                                  ),
                                ),
                                Text(
                                  'myFutureTime',
                                  style: TextStyle(
                                    fontSize: size.width * 0.06,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Inter',
                                    color: Color(0xFFFF9933),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => InboxPage()),
                                    );
                                  },
                                  child: Container(
                                    width: iconSize,
                                    height: iconSize,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Color(0xFFFF9933)),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(Icons.inbox, color: Color(0xFFFF9933)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        FutureBuilder<List<Offer>>(
  future: _offersFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else if (snapshot.hasData) {
      final offers = snapshot.data!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.31, // 30% of the screen height
            child: PageView.builder(
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return OfferWidget(offer: offer);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllOffersPage()),
                );
              },
              child: Text(
                'See More...',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontFamily: 'Inter',
                  color: Color(0xFFFF9933),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(child: Text('No offers available'));
    }
  },
),

                        SizedBox(height: 10),
FutureBuilder<DashboardData>(
  future: _dashboardDataFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      // While the data is being fetched
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      // Handle errors gracefully
      return Center(child: Text('Data is being generated, please wait...'));
    } else if (snapshot.hasData) {
      final data = snapshot.data!;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCircleSection(
              context,
              title: 'Horoscope',
              imageUrl: 'assets/images/horoscope2.png',
              imageWidth: circleSize * 0.67,
              imageHeight: circleSize * 0.75,
              page: HoroscopePage(),
              rating: data.horoscope.rating,
            ),
            SizedBox(height: 16),
            _buildCircleSection(
              context,
              title: 'Compatibility',
              imageUrl: 'assets/images/compatibility2.png',
              imageWidth: circleSize * 0.67,
              imageHeight: circleSize * 0.55,
              page: CompatibilityPage(),
              compatibility: data.compatibility,
            ),
            SizedBox(height: 16),
            _buildCircleSection(
              context,
              title: 'Auspicious Time',
              imageUrl: 'assets/images/auspicious2.png',
              imageWidth: circleSize * 0.67,
              imageHeight: circleSize * 0.75,
              page: AuspiciousTimePage(),
              rating: data.auspicious.rating,
            ),
          ],
        ),
      );
    } else {
      // Handle the case where data is not available for any other reason
      return Center(child: Text('Data is being generated, please wait...'));
    }
  },
),

                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            left: _isMenuOpen ? 0 : -size.width * 0.8,
            top: 0,
            bottom: 0,
            child: Menu(
            ),
          ),
        ],
      ),
        bottomNavigationBar: BottomNavBar(screenWidth: screenWidth, screenHeight: screenHeight),
    );
  }
  

  Widget _buildCircleSection(
  BuildContext context, {
  required String title,
  required String imageUrl,
  required double imageWidth,
  required double imageHeight,
  required Widget page,
  int? rating,
  String? compatibility,
}) {
  final size = MediaQuery.of(context).size;
  final double circleSize = size.width * 0.18;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Center align the Row
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Color(0xFFFF9933),
                  width: 3,
                ),
              ),
              child: Center(
                child: Image.asset(
                  imageUrl,
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: 40), // Adjust spacing between the image and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Center details vertically
                children: [
                  if (rating != null) // Display rating if available
                    Text(
                      'Rating: $rating',
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        fontFamily: 'Inter',
                        color: Colors.black, // Black color for details
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  if (compatibility != null) // Display compatibility if available
                    Text(
                      compatibility,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        fontFamily: 'Inter',
                        color: Colors.black, // Black color for details
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16), // Spacing between the Row and the title
        Text(
          title,
          style: TextStyle(
            fontSize: size.width * 0.04,
            fontFamily: 'Inter',
            color: Color(0xFFC06500),
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
}
