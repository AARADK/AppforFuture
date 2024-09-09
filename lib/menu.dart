import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/astrologers/ui/astrologer_page.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page2.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/profile/ui/profile_details.dart';
import 'package:flutter_application_1/features/settings/ui/settings_page.dart';
import 'package:flutter_application_1/features/sign_up/ui/w1_page.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start the animation on init
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Get screen size
    final double menuWidth = size.width * 0.8; // 80% of screen width

    return SlideTransition(
      position: _offsetAnimation,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/menu.png', // Path to your image
              fit: BoxFit.cover, // Cover the entire container
            ),
          ),
          // Menu content
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: menuWidth, // Use calculated menu width
                height: size.height, // Cover full height
                color: Colors.transparent, // Make the container transparent
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.02), // Adjust top padding
                    Text(
                      'Menu\n',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFC06500),
                        fontSize: size.width * 0.06, // Responsive font size
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02), // Add space between text and logo
                    Center(
                      child: Image.asset(
                        'assets/images/flogo.png', // Path to your logo image
                        height: size.height * 0.2, // Adjust logo height
                      ),
                    ),
                    SizedBox(height: size.height * 0.02), // Add space between logo and items
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildMenuItem(context, 'My Profile', Icons.person, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProfileDetails()),
                              );
                            }),
                            _buildMenuItem(context, 'Horoscope', Icons.stars, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => HoroscopePage()),
                              );
                            }),
                            _buildMenuItem(context, 'Auspicious Time', Icons.access_time, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AuspiciousTimePage()),
                              );
                            }),
                            _buildMenuItem(context, 'Compatibility', Icons.favorite, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CompatibilityPage()),
                              );
                            }),
                            _buildMenuItem(context, 'Our Astrologers', Icons.group, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => OurAstrologersPage()),
                              );
                            }),
                            _buildMenuItem(context, 'Settings', Icons.settings, () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    height: size.height * 0.75, // Adjust bottom sheet height
                                    child: SettingsPage(),
                                  );
                                },
                              );
                            }),
                            _buildMenuItem(context, 'Contact Us', Icons.contact_mail, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ContactUsPage()),
                              );
                            }),
                            _buildMenuItem(context, 'About Us', Icons.info, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AboutUsPage()),
                              );
                            }),
                            _buildMenuItem(context, 'Log out', Icons.logout, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => W1Page()),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String text, IconData icon, Function onTap) {
    final size = MediaQuery.of(context).size;
    final double lineWidth = size.width * 0.7; // Line width relative to screen width

    return Column(
      children: [
        GestureDetector(
          onTap: () => onTap(),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.03, horizontal: size.height * 0.06),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Color(0xFFC06500),
                      fontSize: size.width * 0.045, // Responsive font size
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  icon,
                  color: Color(0xFFFF9933), // Icon color
                  size: size.width * 0.06, // Responsive icon size
                ),
              ],
            ),
          ),
        ),
        Container(
          width: lineWidth, // Use calculated line width
          height: 1, // Line height
          color: Color(0xFFC06500), // Line color
        ),
      ],
    );
  }
}

// Placeholder pages for navigation demonstration

class ContactUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact Us')),
      body: Center(child: Text('Contact Us Page')),
    );
  }
}

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About Us')),
      body: Center(child: Text('About Us Page')),
    );
  }
}
