import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/components/topnavbar.dart';
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
  late Future<List<Offer>> _offersFuture;

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
     bool isTablet = MediaQuery.of(context).size.width > 600;
    final size = MediaQuery.of(context).size;
    final double iconSize = size.width * 0.12;
    final double circleSize = size.width * 0.22;
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
                _closeMenu();
              } else if (details.delta.dx > 6 && !_isMenuOpen) {
                _openMenu();
              }
            },
            child: Column(
              children: [
                TopNavBar(
                  title: 'myFutureTime',
                  leftIcon: Icons.menu,
                  onLeftButtonPressed: _openMenu,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
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
                                    height:isTablet ? size.height * 0.38 : size.height * 0.31, // 31% of screen height
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
                                          fontSize: size.width * 0.04,
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
                        SizedBox(height: size.height * 0.01),
                        FutureBuilder<DashboardData>(
                          future: _dashboardDataFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
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
                                      description: data.horoscope.description,
                                     
                                    ),
                                      SizedBox(height: size.height * 0.03),
                                    _buildCircleSection(
                                      context,
                                      title: 'Compatibility',
                                      imageUrl: 'assets/images/compatibility2.png',
                                      imageWidth: circleSize * 0.67,
                                      imageHeight: circleSize * 0.55,
                                      page: CompatibilityPage(),
                                      compatibility: data.compatibility,
                                    ),
                                     SizedBox(height: size.height * 0.03),
                                    _buildCircleSection(
                                      context,
                                      title: 'Auspicious Time',
                                      imageUrl: 'assets/images/auspicious2.png',
                                      imageWidth: circleSize * 0.67,
                                      imageHeight: circleSize * 0.75,
                                      page: AuspiciousTimePage(),
                                      description: data.auspicious.description,
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Center(child: Text('Data is being generated, please wait...'));
                            }
                          },
                        ),
                          SizedBox(height: size.height * 0.03),
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
            child: Menu(),
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
  String? description,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFFF9933)),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(imageUrl, width: imageWidth, height: imageHeight),
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title in #FF9933
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9933), // Title color set to #FF9933
                    ),
                  ),
                  if (description != null)
                    // Rating in black
                    Text(
                          description,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: size.width * 0.03,
                            fontFamily: 'Inter',
                            color: Colors.black, // Black for compatibility details
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 3, // Allow text to wrap
                        ),
                  if (compatibility != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        // Compatibility data in black
                        Text(
                          compatibility,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: size.width * 0.03,
                            fontFamily: 'Inter',
                            color: Colors.black, // Black for compatibility details
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 3, // Allow text to wrap
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  }

